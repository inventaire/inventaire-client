import { derived, writable } from 'svelte/store'
import { API } from '#app/api/api'
import app from '#app/app'
import preq, { treq } from '#app/lib/preq'
import type { GetUserGroupsResponse } from '#server/controllers/groups/get_user_groups'
import type { Group } from '#server/types/group'
import { getMainUserGroupStatus, serializeGroup, type SerializedGroup } from './groups'

export let userGroups: SerializedGroup[] = []

export const userGroupsStore = writable(userGroups)

async function fetchUserGroups () {
  const res = await treq.get<GetUserGroupsResponse>(API.groups.base)
  userGroups = res.groups.map(group => serializeGroup(group))
  app.execute('waiter:resolve', 'groups')
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
  userGroups.push(group)
  userGroupsStore.set(userGroups)
  return group
}
