import { forceArray } from 'lib/utils'
import log_ from 'lib/loggers'
import preq from 'lib/preq'
export default {
  get (ids, format = 'index', refresh) {
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

  async search (text) {
    // catches case with ''
    if (_.isEmpty(text)) return []

    return preq.get(app.API.users.search(text))
    .then(({ users }) => users)
    .catch(log_.ErrorRethrow('users_data search err'))
  },

  async byUsername (username) {
    return preq.get(app.API.users.byUsername(username))
    .then(({ users }) => users[username])
  },

  async searchByPosition (latLng) {
    return preq.get(app.API.users.searchByPosition(latLng))
    .then(({ users }) => users)
    .catch(log_.Error('searchByPosition err'))
  }
}

const getUsersByIds = ids => preq.get(app.API.users.byIds(ids)).then(({ users }) => users)

const formatData = (format, data) => {
  if (format === 'collection') return _.values(data)
  else return data
}
