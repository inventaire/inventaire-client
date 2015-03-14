module.exports = ->
  if navigator.id?
    navigator.id.logout()
    navigator.id.watch
      onlogin: onlogin
      onlogout: onlogout
  else unreachablePersona()

  app.commands.setHandlers
    'persona:login:request': requestPersonaLogin

requestPersonaLogin = ->
  if navigator.id? then navigator.id.request()
  else unreachablePersona()

unreachablePersona = ->
  console.error 'Persona Login not available: you might be offline'

onlogin = (assertion) ->
  app.execute 'login',
    assertion: assertion
    strategy: 'browserid'
    # needed on signup requests
    username: app.user.get('username')
  .catch loginError

onlogout = ->
  app.vent.trigger 'debug', arguments, 'fake logout: avoid login loop'

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
