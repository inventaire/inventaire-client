import { derived, writable } from 'svelte/store'
import { API } from '#app/api/api'
import preq from '#app/lib/preq'
import { commands, reqres } from '#app/radio'
import type { RelationAction } from '#server/controllers/relations/actions'
import type { GetRelationsResponse } from '#server/controllers/relations/get'
import type { UserId } from '#server/types/user'
import { mainUser } from '#user/lib/main_user'
import { getCachedSerializedUsers } from '../helpers'
import type { SerializedUser } from './users'

export let relations: GetRelationsResponse = {
  friends: [],
  userRequested: [],
  otherRequested: [],
  network: [],
}

export const relationsStore = writable(relations)

export async function fetchRelations () {
  await reqres.request('wait:for', 'user')
  if (mainUser.loggedIn) {
    relations = await preq.get(API.relations)
  }
  commands.execute('waiter:resolve', 'relations')
  relationsStore.set(relations)
  return relations
}

let waitingForRelations
export function getRelations () {
  waitingForRelations ??= fetchRelations()
  return waitingForRelations
}

export const initRelations = getRelations

export async function refreshRelations () {
  waitingForRelations = null
  await getRelations()
}

export async function getFriendshipRequests () {
  const relations = await getRelations()
  const userIds = relations.otherRequested as UserId[]
  return getCachedSerializedUsers(userIds)
}

export async function getFriends () {
  const relations = await getRelations()
  const userIds = relations.friends as UserId[]
  return getCachedSerializedUsers(userIds)
}

export function getUserRelationStatus (userId: UserId) {
  if (relations.friends.includes(userId)) {
    return 'friends'
  } else if (relations.userRequested.includes(userId)) {
    return 'userRequested'
  } else if (relations.otherRequested.includes(userId)) {
    return 'otherRequested'
  } else if (relations.network.includes(userId)) {
    return 'nonRelationGroupUser'
  } else {
    return 'public'
  }
}

export async function updateRelationStatus (user: SerializedUser, action: RelationAction) {
  const { _id: userId } = user
  await preq.post(API.relations, { action, user: userId })
  await refreshRelations()
}

export const friendshipRequestsCount = derived(relationsStore, $relationsStore => {
  return $relationsStore.otherRequested.length
})
