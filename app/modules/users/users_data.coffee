module.exports =
  get: (ids, format = 'index', refresh)->
    ids = _.forceArray ids

    if ids.length is 0
      promise = _.preq.resolve {}
    else
      promise = getUsersByIds ids

    return promise
    .then formatData.bind(null, format)
    .catch _.ErrorRethrow('users_data get err')

  search: (text)->
    # catches case with ''
    if _.isEmpty(text) then return _.preq.resolve []

    _.preq.get app.API.users.search(text)
    .get 'users'
    .catch _.ErrorRethrow('users_data search err')

  byUsername: (username)->
    _.preq.get app.API.users.byUsername(username)
    .then (res)-> res.users[username]

  searchByPosition: (latLng)->
    _.preq.get app.API.users.searchByPosition(latLng)
    .get 'users'
    .catch _.Error('searchByPosition err')

getUsersByIds = (ids)->
  _.preq.get app.API.users.byIds(ids)
  .get 'users'

formatData = (format, data)->
  if format is 'collection' then return _.values data
  else return data
