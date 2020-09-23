fetchData = require 'lib/data/fetch'
MainUser = require '../models/main_user'
cookie_ = require 'js-cookie'

module.exports = (app)->
  # the cookie is deleted on logout
  loggedIn = _.parseBooleanString cookie_.get('loggedIn')

  fetchData
    name: 'user'
    Collection: MainUser
    condition: loggedIn
  .catch resetSession

  app.user.loggedIn = loggedIn

# Known cases of session errors:
# - when the server secret is changed
# - when the current session user was deleted but the cookies weren't removed
#   (possibly because the deletion was done from another browser or even another device)
resetSession = (err)->
  app.execute 'logout', '/login'
