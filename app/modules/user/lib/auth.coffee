requestLogout = require './request_logout'

module.exports = ->
  app.reqres.setHandlers
    'login:classic': requestClassicLogin
    'login:persona': requestPersonaLogin

  app.commands.setHandlers
    'logout': requestLogout

requestClassicLogin = (username, password)->
  requestLogin
    strategy: 'local'
    username: username
    password: password

# can only be called by persona onlogin method
requestPersonaLogin = (assertion)->
  requestLogin
    strategy: 'browserid'
    assertion: assertion
    # needed on signup requests
    username: localStorage.getItem('username')

requestLogin = (input)->
  _.log input, 'user:login'

  # error catching is handled per-strategy
  _.preq.post(app.API.auth.login, input)
  .then loginSuccess

loginSuccess = ->
  # will get user data on reload's fetch
  window.location.reload()

