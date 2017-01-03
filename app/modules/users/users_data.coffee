module.exports =
  get: (ids, format='index', refresh)->
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

  findOneByUsername: (username)->
    @search(username)
    .then (res)->
      user = res?[0]
      # ignoring case as the user database does
      if user?.username.toLowerCase() is username.toLowerCase()
        return user

  searchByPosition: (latLng)->
    _.preq.get app.API.users.searchByPosition(latLng)
    .get 'users'
    .catch _.Error('searchByPosition err')

getUsersByIds = (ids)->
  _.preq.get app.API.users.data(ids)
  .get 'users'

formatData = (format, data)->
  if format is 'collection' then return _.values data
  else return data
