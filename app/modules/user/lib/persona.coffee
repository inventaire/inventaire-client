module.exports = ->
  app.commands.setHandlers
    'persona:login:request': requestPersonaLogin
    'persona:logout:request': requestPersonaLogout

# fetching Persona script just in time
# to avoid weird re-login after logout
# As the window reloads at login, navigator.id / Persona script
# won't be there anymore, hypothetically suppressing the need to logout
requestPersonaLogin = ->
  preparePersona()
  .then makeRequest
  .catch _.Error('Persona Login err')

preparePersona = ->
  if navigator.id? then _.preq.resolve()
  else
    _.preq.getScript app.API.scripts.persona
    .then initPersona

initPersona = ->
  navigator.id.watch
    onlogin: onlogin
    onlogout: onlogout

makeRequest = ->
  navigator.id.request()

# shouldn't pass navigator.id? test
# see requestPersonaLogin explanation
requestPersonaLogout = ->
  if navigator.id? then navigator.id.logout()

onlogin = (assertion) ->
  app.request 'login:persona', assertion
  .catch loginError

onlogout = -> console.warn 'persona logout?! not supposed to happen'

loginError = (err)->
  _.logXhrErr err, 'login err'
  app.request 'ifOnline', showAccountError, true

showAccountError = ->
  app.execute 'show:error',
    message: _.i18n "missing_account_title"
    redirection:
      href: '/signup/persona'
      legend: _.i18n 'missing_account_legend'
      text: _.i18n 'create an account'
      classes: 'dark-grey'
      buttonAction: ->
        app.execute 'show:signup:persona'
