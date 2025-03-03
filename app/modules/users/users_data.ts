import { uniq } from 'underscore'
import { API } from '#app/api/api'
import { newError } from '#app/lib/error'
import log_ from '#app/lib/loggers'
import preq, { treq } from '#app/lib/preq'
import { forceArray } from '#app/lib/utils'
import type { GetUsersByAcctsResponse } from '#server/controllers/users/by_accts'
import type { UserAccountUri } from '#server/types/server'
import type { User, UserId, Username } from '#server/types/user'
import { serializeContributor, serializeUser, type SerializedContributor } from './lib/users'

export async function searchUsers (text) {
  // catches case with ''
  if (!text) return []
  const { users } = await preq.get(API.users.search(text))
  return users
}

export default {
  get (ids, format = 'index') {
    let promise
    ids = forceArray(ids)

    if (ids.length === 0) {
      promise = Promise.resolve({})
    } else {
      promise = getUsersByIds(ids)
    }

    return promise
    .then(formatData.bind(null, format))
    .catch(log_.ErrorRethrow('users_data get err'))
  },

  search: searchUsers,
}

export async function getUsersByIds (ids: UserId[]) {
  if (ids.length === 0) return {}
  const { users } = await preq.get(API.users.byIds(ids))
  return users
}

const formatData = (format, data) => {
  if (format === 'collection') return Object.values(data)
  else return data
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
