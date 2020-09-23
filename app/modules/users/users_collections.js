Users = require './collections/users'

module.exports = (app)->
  users = new Users

  users.filtered = new FilteredCollection users
  users.filtered.friends = ->
    @resetFilters()
    @filterBy { status: 'friends' }
    return users.filtered

  waiters = {}
  fetched = {}
  fetcher = (category, initFilteredCollection)-> ()->
    if fetched[category] then return waiters[category]

    fetched[category] = true
    waiters[category] = app.request 'wait:for', 'relations'
      .then -> app.request 'get:users:models', app.relations[category]
      .then (models)->
        users[category] = new Users models
        if initFilteredCollection
          users[category].filtered = new FilteredCollection users[category]

    return waiters[category]

  app.reqres.setHandlers
    'fetch:friends': fetcher 'friends', true
    'fetch:otherRequested': fetcher 'otherRequested'

  return users
