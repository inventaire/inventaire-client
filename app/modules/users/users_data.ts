import { API } from '#app/api/api'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import { forceArray } from '#app/lib/utils'

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

  async byUsername (username) {
    return preq.get(API.users.byUsername(username))
    .then(({ users }) => users[username])
  },
}

export async function getUsersByIds (ids) {
  if (ids.length === 0) return {}
  const { users } = await preq.get(API.users.byIds(ids))
  return users
}

const formatData = (format, data) => {
  if (format === 'collection') return Object.values(data)
  else return data
}

export async function getUserById (id) {
  const users = await getUsersByIds([ id ])
  return users[id]
}
