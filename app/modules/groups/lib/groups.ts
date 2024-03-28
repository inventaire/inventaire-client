import { findWhere, pluck, without } from 'underscore'
import app from '#app/app'
import { pass } from '#general/lib/forms'
import error_ from '#lib/error'
import { getColorSquareDataUriFromModelId } from '#lib/images'
import log_ from '#lib/loggers'
import preq from '#lib/preq'
import { fixedEncodeURIComponent } from '#lib/utils'
import { getCachedSerializedUsers } from '#users/helpers'
import { serializeUser } from '#users/lib/users'
import { getUserById } from '#users/users_data'

export default {
  createGroup (data) {
    const { name, description, searchable, open, position } = data
    const { groups } = app

    return preq.post(app.API.groups.base, {
      action: 'create',
      name,
      description,
      searchable,
      open,
      position,
    })
    .then(groups.add.bind(groups))
    .then(log_.Info('group'))
    .catch(error_.Complete('#createGroup'))
  },

  validateName (name, selector) {
    pass({
      value: name,
      tests: groupNameTests,
      selector,
    })
  },

  validateDescription (description, selector) {
    pass({
      value: description,
      tests: groupDescriptionTests,
      selector,
    })
  },
}

const groupNameTests = {
  'The group name can not be longer than 80 characters' (name) {
    return name.length > 80
  },
}

const groupDescriptionTests = {
  'The group description can not be longer than 5000 characters' (description) {
    return description.length > 5000
  },
}

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
  return group.picture || getColorSquareDataUriFromModelId(group._id)
}

export function getGroupPathname (group) {
  return `/groups/${group.slug}`
}

const memberIsMainUser = ({ user }) => user === app.user.id

export function mainUserIsGroupAdmin (group) {
  return group.admins.find(memberIsMainUser) != null
}

function mainUserIsGroupNonAdminMember (group) {
  return group.members.find(memberIsMainUser) != null
}

export function mainUserIsGroupMember (group) {
  return mainUserIsGroupAdmin(group) || mainUserIsGroupNonAdminMember(group)
}

export function getUserGroupStatus (userId, group) {
  if (getAllGroupMembersIds(group).includes(userId)) return 'member'
  if (getGroupInvitedUsersIds(group).includes(userId)) return 'invited'
  if (getGroupRequestingUsersIds(group).includes(userId)) return 'requested'
  return 'none'
}

export const getMainUserGroupStatus = group => getUserGroupStatus(app.user.id, group)

export async function getCachedSerializedGroupMembers (group) {
  const allMembersIds = getAllGroupMembersIds(group)
  return getCachedSerializedUsers(allMembersIds)
}

export function serializeGroup (group, options) {
  if (group._serialized && !(options?.refresh)) return group
  const slug = fixedEncodeURIComponent(group.slug)
  const base = `/groups/${slug}`
  if (group.picture == null) {
    group.picture = getColorSquareDataUriFromModelId(group._id)
  }
  const mainUserIsAdmin = mainUserIsGroupAdmin(group)
  return Object.assign(group, {
    _serialized: true,
    canonical: base,
    pathname: base,
    inventoryPathname: `${base}/inventory`,
    listingsPathname: `${base}/lists`,
    settingsPathname: `${base}/settings`,
    mainUserIsAdmin,
    mainUserIsMember: mainUserIsAdmin || mainUserIsGroupNonAdminMember(group),
    mainUserStatus: getMainUserGroupStatus(group),
  })
}

export async function getGroup (groupId) {
  const { group } = await preq.get(app.API.groups.byId(groupId))
  return group
}

export async function getGroupBySlug (slug) {
  const { group } = await preq.get(app.API.groups.bySlug(slug))
  return group
}

function findMembership (group, category, userId) {
  return findWhere(group[category], { user: userId })
}

export function findInvitation (group, userId) {
  return findMembership(group, 'invited', userId)
}

export async function findMainUserInvitor (group) {
  const invitation = findInvitation(group, app.user.id)
  if (invitation) return getUserById(invitation.invitor)
}

export async function updateGroupSetting ({ groupId, attribute, value }) {
  return preq.put(app.API.groups.base, {
    action: 'update-settings',
    group: groupId,
    attribute,
    value,
  })
}

async function groupAction (action, groupId, targetUserId) {
  return preq.put(app.API.groups.base, {
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

export function moveMembership (group, userId, previousCategory, newCategory) {
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
