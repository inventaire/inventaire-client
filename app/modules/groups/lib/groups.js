import log_ from '#lib/loggers'
import preq from '#lib/preq'
import forms_ from '#general/lib/forms'
import error_ from '#lib/error'
import { pluck } from 'underscore'
import { getColorSquareDataUriFromModelId } from '#lib/images'
import { fixedEncodeURIComponent } from '#lib/utils'

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
      position
    })
    .then(groups.add.bind(groups))
    .then(log_.Info('group'))
    .catch(error_.Complete('#createGroup'))
  },

  validateName (name, selector) {
    forms_.pass({
      value: name,
      tests: groupNameTests,
      selector
    })
  },

  validateDescription (description, selector) {
    forms_.pass({
      value: description,
      tests: groupDescriptionTests,
      selector
    })
  }
}

const groupNameTests = {
  'The group name can not be longer than 80 characters' (name) {
    return name.length > 80
  }
}

const groupDescriptionTests = {
  'The group description can not be longer than 5000 characters' (description) {
    return description.length > 5000
  }
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

export async function getAllGroupMembersDocs (group) {
  const allMembersIds = getAllGroupMembersIds(group)
  return app.request('get:users', allMembersIds)
}

export function serializeGroup (group) {
  if (group._serialized) return group
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
