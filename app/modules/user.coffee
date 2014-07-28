module.exports = (module, app, Backbone, Marionette, $, _) ->
  # LOGIC
  initializePersona(app)
  app.user = new app.Model.User
  recoverUserData(app)

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
            console.log 'error onlogin: invalid data'
      onlogout: ()->
        app.vent.trigger 'debug', arguments, 'fake logout: avoid login loop'
  else
    console.log 'Persona Login not available: you might be offline'

  app.commands.setHandlers
    'persona:login': -> navigator.id.request()
    'persona:logout': ->
      $.post app.API.auth.logout, (data)->
        window.location.reload()
        console.log "You have been logged out"

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
