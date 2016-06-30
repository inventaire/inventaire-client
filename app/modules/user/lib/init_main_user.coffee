fetchData = require 'lib/data/fetch'
MainUser = require '../models/main_user'

module.exports = (app)->
  # the cookie is deleted on logout
  loggedIn = _.getCookie('loggedIn')?

  fetchData
    name: 'user'
    Collection: MainUser
    condition: loggedIn
  .catch resetSession

  app.user.loggedIn = loggedIn

resetSession = ->
  app.user.loggedIn = false
  # commented-out as it seem to be responsible for random logout, in development at least
  # app.execute 'logout'
