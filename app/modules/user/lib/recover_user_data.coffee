module.exports = (app)->
  # set app.user.lang from cookie before confirmation
  # from user.fetch which will trigger setLang on User model
  if $.cookie('lang')
    app.user.lang or= $.cookie('lang')


  if $.cookie('loggedIn')?
    app.user.loggedIn = true

    app.user.fetch()
    .then (userAttrs)->
      unless app.user.get('language')?
        if lang = $.cookie 'lang'
          _.log app.user.set('language', lang), 'language set from cookie'
    # beware: Backbone uses jQuery promise not wrapped by bluebird/preq
    .fail (err)->
      _.logXhrErr(err, 'recoverUserData fail')
    .always ->
      app.vent.trigger 'user:ready'
      app.user.fetched = true
  else
    app.user.loggedIn = false
    app.vent.trigger 'user:ready'
    app.user.fetched = true
