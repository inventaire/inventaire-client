module.exports = (module, app, Backbone, Marionette, $, _) ->
  initializeAccountMenu(app)
  initializePersona(app)
  initializeSignupLoginProcess(app)
  recoverUserData(app)

initializeAccountMenu = (app)->
  app.user.on 'change', (user)->
    if user.has 'email'
      app.layout.accountMenu.show new app.View.AccountMenu {model: user}
    else
      app.layout.accountMenu.show new app.View.NotLoggedMenu

initializePersona = (app)->
  if navigator.id?
    navigator.id.logout()
    navigator.id.watch
      onlogin: (assertion) ->
        token = $('#token').val()
        $.post "/auth/login", {assertion: assertion, username: app.user.get('username'), _csrf: token}, (data)->
          if typeof data is 'object'
            user = JSON.stringify(data)
            user.loggedIn = true
            localStorage.setItem 'user', user
            window.location.reload()
          else
            console.log 'error onlogin: invalid data'
            window.data = data
      onlogout: ()->
        app.vent.trigger 'debug', arguments, 'fake logout: avoid login loop'
  else
    console.log 'Persona Login not available: you might be offline'

  app.commands.setHandler 'persona:login', -> navigator.id.request()
  app.commands.setHandler 'persona:logout', ->
    localStorage.removeItem('user')
    $.post "/auth/logout", (data)->
      window.location.reload()
      console.log "You have been logged out"

initializeSignupLoginProcess = (app)->
  app.commands.setHandler 'signup:request', ->
    app.layout.modal.show new app.View.Signup.Step1 {model: app.user}

  app.commands.setHandler 'signup:validUsername', ->
    app.layout.modal.show new app.View.Signup.Step2 {model: app.user}

  app.commands.setHandler 'login:request', ->
    app.layout.modal.show new app.View.Login.Step1 {model: app.user}


recoverUserData = (app)->
  if $.cookie('email')? && localStorage.getItem('user')?
    data = JSON.parse localStorage.getItem('user')
    app.user.loggedIn = data.loggedIn = true
    app.user.set _.pick(data, 'username', 'email', 'pic', 'created', 'loggedIn')
    app.vent.trigger 'user:data', data
  else
    # triggers a change to update the account menu
    app.user.set('loggedIn', app.user.loggedIn = false)