module.exports = (app, _)->
  get: (ids)->
    _.preq.get app.API.users.data(ids)
    .catch _.Error('users_data get err')

  search: (text)->
    # catches case with ''
    if _.isEmpty(text) then return _.preq.resolve []

    _.preq.get app.API.users.search(text)
    .then _.property('users')
    .catch _.Error('users_data search err')


  findOneByUsername: (username)->
    @search(username)
    .then (res)->
      user = res?[0]
      # ignoring case as the user database does
      if user?.username.toLowerCase() is username.toLowerCase()
        return user

  searchByPosition: (latLng)->
    _.preq.get app.API.users.searchByPosition(latLng)
    .then _.property('users')
    .catch _.Error('searchByPosition err')
