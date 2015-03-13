module.exports = (app)->
  # set app.user.lang from cookie before confirmation
  # from user.fetch which will trigger setLang on User model
  if $.cookie('lang')
    app.user.lang or= $.cookie('lang')


  if $.cookie('loggedIn')?
    app.user.loggedIn = true
    fetchUser()
  else
    app.user.loggedIn = false
    userReady()


fetchUser = ->
  # beware: Backbone uses jQuery promise not wrapped by bluebird/preq
  app.user.fetch()
  .then fetchSuccess
  .fail fetchError
  .always userReady

fetchSuccess = (userAttrs)->
  unless app.user.get('language')?
    if lang = $.cookie 'lang'
      _.log app.user.set('language', lang), 'language set from cookie'

fetchError =  (err)->
  _.logXhrErr(err, 'recoverUserData fail')
  resetSession()

userReady = ->
  app.vent.trigger 'user:ready'
  app.user.fetched = true

resetSession = ->
  app.user.loggedIn = false
  app.execute 'persona:logout'