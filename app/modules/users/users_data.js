export default {
  get (ids, format = 'index', refresh) {
    let promise
    ids = _.forceArray(ids)

    if (ids.length === 0) {
      promise = Promise.resolve({})
    } else {
      promise = getUsersByIds(ids)
    }

    return promise
    .then(formatData.bind(null, format))
    .catch(_.ErrorRethrow('users_data get err'))
  },

  search (text) {
    // catches case with ''
    if (_.isEmpty(text)) { return Promise.resolve([]) }

    return _.preq.get(app.API.users.search(text))
    .get('users')
    .catch(_.ErrorRethrow('users_data search err'))
  },

  byUsername (username) {
    return _.preq.get(app.API.users.byUsername(username))
    .then(res => res.users[username])
  },

  searchByPosition (latLng) {
    return _.preq.get(app.API.users.searchByPosition(latLng))
    .get('users')
    .catch(_.Error('searchByPosition err'))
  }
}

const getUsersByIds = ids => _.preq.get(app.API.users.byIds(ids))
.get('users')

const formatData = function (format, data) {
  if (format === 'collection') {
    return _.values(data)
  } else { return data }
}
