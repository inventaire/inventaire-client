fetchData = require 'lib/data/fetch'
MainUser = require '../models/main_user'
cookie_ = require 'lib/cookie'

module.exports = (app)->
  # the cookie is deleted on logout
  loggedIn = cookie_.get('loggedIn')?

  fetchData
    name: 'user'
    Collection: MainUser
    condition: loggedIn
  .catch resetSession

  app.user.loggedIn = loggedIn

# Known cases of session errors:
# - when the server secret is changed
resetSession = (err)->
  app.execute 'logout', '/login'
