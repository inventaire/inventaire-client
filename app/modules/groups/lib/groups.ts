import { findWhere, pluck, without } from 'underscore'
import { API } from '#app/api/api'
import app from '#app/app'
import { isGroupId } from '#app/lib/boolean_tests'
import { newError } from '#app/lib/error'
import { getColorSquareDataUriFromCouchUuId } from '#app/lib/images'
import preq from '#app/lib/preq'
import { fixedEncodeURIComponent } from '#app/lib/utils'
import type { RelativeUrl } from '#server/types/common'
import type { Group, GroupId, GroupMembershipCategory, GroupSlug } from '#server/types/group'
import type { GroupImagePath, ImageDataUrl } from '#server/types/image'
import type { UserId } from '#server/types/user'
import { getCachedSerializedUsers } from '#users/helpers'
import { serializeUser } from '#users/lib/users'
import { getUserById } from '#users/users_data'
import type { OverrideProperties } from 'type-fest'

interface SerializedGroupExtra {
  canonical: RelativeUrl
  pathname: RelativeUrl
  inventoryPathname: RelativeUrl
  listingsPathname: RelativeUrl
  settingsPathname: RelativeUrl
  mainUserIsAdmin: boolean
  mainUserIsMember: boolean
  mainUserStatus: ReturnType<typeof getUserGroupStatus>
}

interface SerializedGroupOverrides {
  // TODO: user another attribute to avoid the need to override
  picture: GroupImagePath | ImageDataUrl
}

export type SerializedGroup = OverrideProperties<Group, SerializedGroupOverrides> & SerializedGroupExtra

export function getAllGroupMembersIds (group) {
  const { admins, members } = group
  return pluck([ ...admins, ...members ], 'user')
}

const getGroupInvitedUsersIds = group => pluck(group.invited, 'user')
const getGroupRequestingUsersIds = group => pluck(group.requested, 'user')

export function getGroupMembersCount (group) {
  return group.admins.length + group.members.length
}

export function getGroupPicture (group) {
  return group.picture || getColorSquareDataUriFromCouchUuId(group._id)
}

export function getGroupPathname (group) {
  return `/groups/${group.slug}`
}

const memberIsMainUser = ({ user }) => user === app.user._id

export function mainUserIsGroupAdmin (group) {
  return group.admins.find(memberIsMainUser) != null
}

function mainUserIsGroupNonAdminMember (group) {
  return group.members.find(memberIsMainUser) != null
}

export function mainUserIsGroupMember (group) {
  return mainUserIsGroupAdmin(group) || mainUserIsGroupNonAdminMember(group)
}

export function getUserGroupStatus (userId: UserId, group: Group | SerializedGroup) {
  if (getAllGroupMembersIds(group).includes(userId)) return 'member'
  if (getGroupInvitedUsersIds(group).includes(userId)) return 'invited'
  if (getGroupRequestingUsersIds(group).includes(userId)) return 'requested'
  return 'none'
}

export const getMainUserGroupStatus = (group: Group | SerializedGroup) => getUserGroupStatus(app.user._id, group)

export async function getCachedSerializedGroupMembers (group) {
  const allMembersIds = getAllGroupMembersIds(group)
  return getCachedSerializedUsers(allMembersIds)
}

export function serializeGroup (group: (Group & Partial<SerializedGroupExtra>) | SerializedGroup, options?: { refresh: boolean }) {
  if ('pathname' in group && !options?.refresh) return group as SerializedGroup
  const slug = fixedEncodeURIComponent(group.slug)
  const base = `/groups/${slug}`
  group.picture ??= getColorSquareDataUriFromCouchUuId(group._id)
  const mainUserIsAdmin = mainUserIsGroupAdmin(group)
  return Object.assign(group, {
    canonical: base,
    pathname: base,
    inventoryPathname: `${base}/inventory`,
    listingsPathname: `${base}/lists`,
    settingsPathname: `${base}/settings`,
    mainUserIsAdmin,
    mainUserIsMember: mainUserIsAdmin || mainUserIsGroupNonAdminMember(group),
    mainUserStatus: getMainUserGroupStatus(group),
  }) as SerializedGroup
}

export async function getGroup (groupId: GroupId) {
  const { group } = await preq.get(API.groups.byId(groupId))
  return group
}

export const getGroupById = getGroup

export async function getGroupBySlug (slug: string) {
  const { group } = await preq.get(API.groups.bySlug(slug))
  return group
}

function findMembership (group, category, userId) {
  return findWhere(group[category], { user: userId })
}

export function findInvitation (group, userId) {
  return findMembership(group, 'invited', userId)
}

export async function findMainUserInvitor (group) {
  const invitation = findInvitation(group, app.user._id)
  if (invitation) return getUserById(invitation.invitor)
}

export async function updateGroupSetting ({ groupId, attribute, value }) {
  return preq.put(API.groups.base, {
    action: 'update-settings',
    group: groupId,
    attribute,
    value,
  })
}

async function groupAction (action, groupId, targetUserId?) {
  return preq.put(API.groups.base, {
    action,
    group: groupId,
    user: targetUserId,
  })
}

export function acceptGroupInvitation ({ groupId }) {
  return groupAction('accept', groupId)
}
export function declineGroupInvitation ({ groupId }) {
  return groupAction('decline', groupId)
}
export function requestToJoinGroup ({ groupId }) {
  return groupAction('request', groupId)
}
export function cancelJoinGroupRequest ({ groupId }) {
  return groupAction('cancel-request', groupId)
}
export function inviteUserToJoinGroup ({ groupId, invitedUserId }) {
  return groupAction('invite', groupId, invitedUserId)
}
export function acceptRequestToJoinGroup ({ groupId, requesterId }) {
  return groupAction('accept-request', groupId, requesterId)
}
export function refuseRequestToJoinGroup ({ groupId, requesterId }) {
  return groupAction('refuse-request', groupId, requesterId)
}
export function makeUserGroupAdmin ({ groupId, userId }) {
  return groupAction('make-admin', groupId, userId)
}
export function kickUserOutOfGroup ({ groupId, userId }) {
  return groupAction('kick', groupId, userId)
}
export function leaveGroup ({ groupId }) {
  return groupAction('leave', groupId)
}

export function moveMembership (group: Group, userId: UserId, previousCategory?: GroupMembershipCategory, newCategory?: GroupMembershipCategory) {
  const membership = findMembership(group, previousCategory, userId)
  if (previousCategory) group[previousCategory] = without(group[previousCategory], membership)
  if (newCategory) group[newCategory] = group[newCategory].concat([ membership ])
  return group
}

export function serializeGroupUser (group) {
  const adminsIds = new Set(pluck(group.admins, 'user'))
  const membersIds = new Set(pluck(group.members, 'user'))
  const requestedIds = new Set(pluck(group.requested, 'user'))
  const invitedIds = new Set(pluck(group.invited, 'user'))
  const declinedIds = new Set(pluck(group.declined, 'user'))
  return user => {
    user = serializeUser(user)
    user.isGroupAdmin = adminsIds.has(user._id)
    user.isGroupMember = adminsIds.has(user._id) || membersIds.has(user._id)
    user.requestedToJoinGroup = requestedIds.has(user._id)
    user.wasInvitedToJoinGroup = invitedIds.has(user._id)
    user.declinedToJoinGroup = declinedIds.has(user._id)
    return user
  }
}

export async function resolveToGroup (group: Group | GroupId | GroupSlug) {
  let resolvedGroup
  if (typeof group === 'object' && '_id' in group) {
    resolvedGroup = group
  } else if (typeof group === 'string') {
    if (isGroupId(group)) {
      resolvedGroup = await getGroupById(group)
    } else {
      resolvedGroup = await getGroupBySlug(group)
    }
  }
  if (resolvedGroup) return serializeGroup(resolvedGroup)
  else throw newError('can not resolve group', 500, { group })
}
