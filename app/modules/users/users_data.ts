import { uniq } from 'underscore'
import { API } from '#app/api/api'
import { isUserAcct, isUserId } from '#app/lib/boolean_tests'
import { newError } from '#app/lib/error'
import preq, { treq } from '#app/lib/preq'
import type { GetUsersByAcctsResponse } from '#server/controllers/users/by_accts'
import type { GetUsersByIdsResponse } from '#server/controllers/users/by_ids'
import type { UserAccountUri } from '#server/types/server'
import type { User, UserId, Username } from '#server/types/user'
import { serializeContributor, serializeUser, type SerializedContributor } from './lib/users'

export async function searchUsers (text) {
  // catches case with ''
  if (!text) return []
  const { users } = await preq.get(API.users.search(text))
  return users
}

export async function getUsersByIds (ids: UserId[]) {
  if (ids.length === 0) return {}
  const { users } = await treq.get<GetUsersByIdsResponse>(API.users.byIds(ids))
  return users
}

export async function getUserById (id: UserId) {
  const users = await getUsersByIds([ id ])
  return users[id]
}

export async function getSerializedUser (id: UserId) {
  const user = await getUserById(id)
  return serializeUser(user)
}

export async function getUserByUsername (username: Username) {
  const { users } = await preq.get(API.users.byUsername(username))
  return Object.values(users)[0] as User
}

type UsersByAccts = Record<UserAccountUri, SerializedContributor>

export async function getUsersByAccts (userAccts: UserAccountUri[]): Promise<UsersByAccts> {
  userAccts = uniq(userAccts)
  if (userAccts.length === 0) return {}
  const { users } = await treq.get<GetUsersByAcctsResponse>(API.users.byAccts(userAccts))
  Object.values(users).forEach(serializeContributor)
  return users as UsersByAccts
}

export async function getUserByAcct (userAcct: UserAccountUri) {
  const users = await getUsersByAccts([ userAcct ])
  const user = users[userAcct]
  if (!user) throw newError('user not found', 404, { userAcct })
  return user
}

export async function resolveToUser (user: User | UserId | Username) {
  let resolvedUser
  if (typeof user === 'object' && '_id' in user) {
    resolvedUser = user
  } else if (isUserId(user)) {
    resolvedUser = await getUserById(user)
  } else if (isUserAcct(user)) {
    const contributor = await getUserByAcct(user)
    if (contributor._id) resolvedUser = await getUserById(user)
  } else if (typeof user === 'string') {
    resolvedUser = await getUserByUsername(user)
  }
  if (resolvedUser) return serializeUser(resolvedUser)
  else throw newError('can not resolve user', 500, { user })
}
