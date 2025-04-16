import { pick } from 'underscore'
import { objectEntries, objectValues } from '#app/lib/utils'
import type { UserId } from '#server/types/user'
import { serializeUser, type ServerUser } from '#users/lib/users'
import { getUsersByIds } from './users_data.ts'

// TODO: add mechanism to empty cache after a time of inactivity
// to not leak memory and keep long outdated data on very long sessions
// (i.e. people never closing their tabs)
const cachedSerializedUsers = {}

// TODO: handle special case of main user, for which we might have fresher data
export async function getCachedSerializedUsers (ids: UserId[]) {
  const missingUsersIds = ids.filter(isntCached)
  // TODO: cache promises instead, to prevent fetching several times the same user in parallel
  const foundUsersByIds = await getUsersByIds(missingUsersIds)
  addSerializedUsersToCache(foundUsersByIds)
  return objectValues(pick(cachedSerializedUsers, ids))
}

const isntCached = id => cachedSerializedUsers[id] == null

function addSerializedUsersToCache (usersByIds: Record<UserId, ServerUser>) {
  for (const [ userId, user ] of objectEntries(usersByIds)) {
    cachedSerializedUsers[userId] = serializeUser(user)
  }
}

export async function getCachedSerializedUser (id: UserId) {
  const [ user ] = await getCachedSerializedUsers([ id ])
  return user
}
