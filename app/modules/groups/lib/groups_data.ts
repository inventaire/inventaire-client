import { API } from '#app/api/api'
import app from '#app/app'
import { treq } from '#app/lib/preq'
import type { GetUserGroupsResponse } from '#server/controllers/groups/get_user_groups'
import type { Group } from '#server/types/group'

export let userGroups: Group[]

async function fetchUserGroups () {
  const res = await treq.get<GetUserGroupsResponse>(API.groups.base)
  userGroups = res.groups
  app.execute('waiter:resolve', 'groups')
}

let fetchingUserGroups
export async function getUserGroups () {
  fetchingUserGroups ??= fetchUserGroups()
  await fetchingUserGroups
  return userGroups
}
