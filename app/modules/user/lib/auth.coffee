requestLogout = require './request_logout'

module.exports = ->
  app.reqres.setHandlers
    'login:classic': requestClassicLogin

  app.commands.setHandlers
    'login:persona': -> app.execute 'persona:login:request'
    'login': requestLogin
    'logout': requestLogout

requestClassicLogin = (username, password)->
  requestLogin
    strategy: 'local'
    username: username
    password: password

requestLogin = (input)->
  _.log input, 'user:login'

  # error catching is handled per-strategy
  _.preq.post(app.API.auth.login, input)
  .then loginSuccess

loginSuccess = ->
  # will get user data on reload's fetch
  window.location.reload()

