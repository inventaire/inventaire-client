import { derived, writable } from 'svelte/store'
import { API } from '#app/api/api'
import preq, { treq } from '#app/lib/preq'
import type { GetUserGroupsResponse } from '#server/controllers/groups/get_user_groups'
import type { Group, GroupId } from '#server/types/group'
import type { UserId } from '#server/types/user'
import { getGroupById, getMainUserGroupStatus, serializeGroup, type SerializedGroup } from './groups'

export let userGroups: SerializedGroup[] = []

export const userGroupsStore = writable(userGroups)

async function fetchUserGroups () {
  const res = await treq.get<GetUserGroupsResponse>(API.groups.base)
  userGroups = res.groups.map(group => serializeGroup(group))
  userGroupsStore.set(userGroups)
}

let fetchingUserGroups
export async function getUserGroups () {
  fetchingUserGroups ??= fetchUserGroups()
  await fetchingUserGroups
  return userGroups
}

export async function getGroupInvitations () {
  const groups = await getUserGroups()
  return groups.filter(group => getMainUserGroupStatus(group) === 'invited')
}

export const userGroupsInvitationsCount = derived(userGroupsStore, ($userGroupsStore: SerializedGroup[]) => {
  return $userGroupsStore.filter(group => getMainUserGroupStatus(group) === 'invited').length
})

export async function createGroup (groupData: Partial<Group>) {
  const group = await preq.post(API.groups.base, { action: 'create', ...groupData })
  const serializedGroup = serializeGroup(group)
  updateUserGroups(serializedGroup)
  return serializedGroup
}

export async function groupAction ({ action, groupId, userId }: { action: string, groupId: GroupId, userId?: UserId }) {
  await preq.put(API.groups.base, {
    action,
    group: groupId,
    // Required only for actions implying an other user
    user: userId,
  })
  const updatedGroup = await getGroupById(groupId)
  const serializedGroup = serializeGroup(updatedGroup)
  updateUserGroups(serializedGroup)
  return serializedGroup
}

function updateUserGroups (group: SerializedGroup) {
  if (getMainUserGroupStatus(group) === 'member') {
    if (!userGroups.find(g => g._id === group._id)) userGroups.push(group)
  } else {
    userGroups = userGroups.filter(g => g._id !== group._id)
  }
  userGroupsStore.set(userGroups)
}
