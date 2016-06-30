module.exports = (app)->
  if _.getCookie('loggedIn')?
    app.user.loggedIn = true
    fetchUserData()
  else
    app.user.loggedIn = false
    userReady()

fetchUserData = ->
  # beware: Backbone uses jQuery promise not wrapped by bluebird/preq
  app.user.fetch()
  .then fetchSuccess
  .fail fetchError
  .always userReady

fetchSuccess = (userAttrs)->

fetchError =  (err)->
  _.error err, 'recoverUserData fail'
  resetSession()

userReady = ->
  app.vent.trigger 'main:user:ready'
  app.user.fetched = true

resetSession = ->
  app.user.loggedIn = false
  # commented-out as it seem to be responsible for random logout, in development at least
  # app.execute 'logout'
