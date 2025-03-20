import { API } from '#app/api/api'
import app from '#app/app'
import { treq } from '#app/lib/preq'
import type { GetUserGroupsResponse } from '#server/controllers/groups/get_user_groups'
import { getMainUserGroupStatus, serializeGroup, type SerializedGroup } from './groups'

export let userGroups: SerializedGroup[]

async function fetchUserGroups () {
  const res = await treq.get<GetUserGroupsResponse>(API.groups.base)
  userGroups = res.groups.map(group => serializeGroup(group))
  app.execute('waiter:resolve', 'groups')
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
