module.exports = (module, app, Backbone, Marionette, $, _) ->
  # LOGIC
  initializePersona(app)
  app.user = new app.Model.User
  recoverUserData(app)
  initializeUserI18nSettings(app)
  initializeUserEditionCommands(app)

  # VIEWS
  initializeAccountMenu(app)
  initializeSignupLoginProcess(app)


# LOGIC
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
          else
            _.log 'error onlogin: invalid data'
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
  _.log $.cookie('testcookie'), 'testcookie'
  _.log $.cookie('email'), 'email cookie'
  if $.cookie('email')?
    _.log app.user, 'user before fetch'
    app.user.fetch()
    app.user.loggedIn = true
    app.user.trigger('change', app.user)
  else
    app.vent.trigger 'debug', arguments, 'chrome deletes cookies on localhost'
    app.user.loggedIn = false
    # triggers a change to update the account menu
    app.user.trigger('change', app.user)

initializeUserI18nSettings = (app)->
  app.user.on 'change:language', (data)->
    if (lang = app.user.get('language')) isnt app.polyglot.currentLocale
      _.log lang, 'user data change: i18n change requested'
      app.request 'i18n:set', lang
      _.setCookie 'lang', lang


initializeUserEditionCommands = (app)->
  app.reqres.setHandlers
    'user:update': (options)->
      app.user.set options.fieldName, options.value
      return app.user.save()

# VIEWS

initializeAccountMenu = (app)->
  app.user.on 'change', (user)->
    if user.has 'email'
      app.layout.accountMenu.show new app.View.AccountMenu {model: user}
    else
      app.layout.accountMenu.show new app.View.NotLoggedMenu

initializeSignupLoginProcess = (app)->
  app.commands.setHandlers
    'signup:request': ->
      app.layout.modal.show new app.View.Signup.Step1 {model: app.user}

    'signup:validUsername': ->
      app.layout.modal.show new app.View.Signup.Step2 {model: app.user}

    'login:request': ->
      app.layout.modal.show new app.View.Login.Step1 {model: app.user}

    'user:edit': ->
      app.layout.main.show new app.View.EditUser {model: app.user}
