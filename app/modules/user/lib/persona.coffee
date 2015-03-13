module.exports = ->
  if navigator.id?
    navigator.id.logout()
    navigator.id.watch
      onlogin: onlogin
      onlogout: onlogout
  else unreachablePersona()

  app.commands.setHandlers
    'persona:login': personaRequestLogin
    'persona:logout': personaRequestLogout

personaRequestLogin = ->
  if navigator.id? then navigator.id.request()
  else unreachablePersona()

personaRequestLogout = ->
  _.preq.post(app.API.auth.logout)
  .then (data)->
    deleteLocalDatabases()
    _.log "You have been successfully logged out"
    window.location.reload()
  .catch (err)-> console.error err, 'error at logout?'

deleteLocalDatabases = ->
  localStorage.clear()
  window.dbs.reset()

unreachablePersona = ->
  console.error 'Persona Login not available: you might be offline'

onlogin = (assertion) ->
  input =
    assertion: assertion
    strategy: 'browserid'
    # needed on signup requests
    username: app.user.get('username')
  _.log input, 'user:login'

  _.preq.post(app.API.auth.login, input)
  .then loginSuccess
  .catch loginError

loginSuccess = ->
  # will get user data on reload's fetch
  window.location.reload()

loginError = (err)->
  _.logXhrErr err, 'login err'
  app.request 'ifOnline', showAccountError, true

showAccountError = ->
  app.execute 'show:error',
    message: _.i18n "missing_account_title"
    redirection:
      href: '/signup'
      legend: _.i18n 'missing_account_legend'
      text: _.i18n 'create an account'
      classes: 'success showSignup'

onlogout = ->
  app.vent.trigger 'debug', arguments, 'fake logout: avoid login loop'
