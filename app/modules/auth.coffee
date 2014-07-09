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

  app.vent.on 'user:nodata', -> app.layout.accountMenu.show new app.View.NotLoggedMenu


initializePersona = (app)->
  if navigator.id?
    navigator.id.logout()
    app.user.set('email', $.cookie('email') || null)
    navigator.id.watch
      onlogin: (assertion) ->
        app.vent.trigger 'persona:onlogin'
        # console.log 'login!!!!!!'
        token = $('#token').val()
        $.post "/auth/login", {assertion: assertion, username: window.username, _csrf: token}, (data)->
          localStorage.setItem 'user', JSON.stringify(data)
          window.location.reload()
      onlogout: ()->
        app.vent.trigger 'persona:onlogout'
        console.log 'fake logout: avoid login loop'
  else
    console.log 'Persona Login not available: you might be offline'
  app.vent.trigger 'persona:start'

  app.vent.on 'persona:request', -> navigator.id.request()
  app.vent.on 'persona:logout', ->
    localStorage.removeItem('user')
    $.post "/auth/logout", (data)->
      window.location.reload()
      console.log "You have been logged out"

initializeSignupLoginProcess = (app)->
  app.vent.on 'signup:request', =>
    app.layout.modal.show new app.View.Signup.Step1 {model: app.user}
    $('#modal').foundation('reveal', 'open')

  app.vent.on 'signup:validUsername', =>
    app.layout.modal.show new app.View.Signup.Step2 {model: app.user}

  app.vent.on 'login:request', =>
    app.layout.modal.show new app.View.Login.Step1 {model: app.user}
    $('#modal').foundation('reveal', 'open')


recoverUserData = (app)->
  if localStorage.getItem('user')?
    data = JSON.parse localStorage.getItem('user')
    app.user.set _.pick(data, 'username', 'email', 'pic', 'created')
    app.vent.trigger 'user:data', data
  else
    app.vent.trigger 'user:nodata'