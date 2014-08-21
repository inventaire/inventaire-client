module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    initializePersona(app)
    app.user = new app.Model.User
    recoverUserData(app)
    initializeUserI18nSettings(app)
    initializeUserEditionCommands(app)
    initializeUserMenuUpdate(app)
    initializeSignupLoginHandlers(app)

initializePersona = (app)->
  if navigator.id?
    navigator.id.logout()
    navigator.id.watch
      onlogin: (assertion) ->
        input =
          assertion: assertion
          username: app.user.get('username')
          _csrf: $('#token').val()
        $.post app.API.auth.login, input, (data)->
          if typeof data is 'object'
            # will get user data on reload's fetch
            window.location.reload()
          else console.error 'onlogin: invalid data'
      onlogout: ()->
        app.vent.trigger 'debug', arguments, 'fake logout: avoid login loop'
  else unreachablePersona()

  app.commands.setHandlers
    'persona:login': ->
      if navigator.id? then navigator.id.request()
      else unreachablePersona()
    'persona:logout': ->
      $.post app.API.auth.logout, (data)->
        window.location.reload()
        _.log "You have been successfully logged out"

unreachablePersona = -> console.error 'Persona Login not available: you might be offline'

recoverUserData = (app)->
  if $.cookie('email')?
    app.user.fetch()
    .then (userAttrs)->
      unless app.user.get('language')?
        if lang = $.cookie 'lang'
          _.log app.user.set('language', lang), 'language set from cookie'
    .fail (err)-> _.log err, 'app.user.fetch fail'
    .done()
    app.user.loggedIn = true
  else
    app.user.loggedIn = false

initializeUserI18nSettings = (app)->
  app.user.on 'change:language', (data)->
    if (lang = app.user.get('language')) isnt app.polyglot.currentLocale
      _.log lang, 'i18n: user data change: i18n change requested'
      app.request 'i18n:set', lang
      _.setCookie 'lang', lang


initializeUserEditionCommands = (app)->
  app.reqres.setHandlers
    'user:update': (options)->
      app.user.set options.fieldName, options.value
      return app.user.save()

initializeUserMenuUpdate = (app)->
  app.commands.setHandlers
    'show:user:menu:update': ->
      if app.user.has 'email'
        app.layout?.accountMenu.show new app.View.AccountMenu {model: app.user}
      else app.layout?.accountMenu.show new app.View.NotLoggedMenu

  app.user.on 'change', (user)-> app.execute 'show:user:menu:update'


initializeSignupLoginHandlers = (app)->
  app.commands.setHandlers
    'show:signup:step1': ->
      app.layout.main.show new app.View.Signup.Step1 {model: app.user}

    'show:signup:step2': ->
      app.layout.main.show new app.View.Signup.Step2 {model: app.user}

    'show:login:step1': ->
      app.layout.main.show new app.View.Login.Step1 {model: app.user}