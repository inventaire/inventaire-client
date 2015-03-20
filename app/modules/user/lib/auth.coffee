requestLogout = require './request_logout'

module.exports = ->
  app.reqres.setHandlers
    'login:classic': requestClassicLogin
    'login:persona': requestPersonaLogin
    'email:confirmation:request': emailConfirmationRequest

  app.commands.setHandlers
    'logout': requestLogout

requestClassicLogin = (username, password)->
  _.preq.post app.API.auth.login,
    strategy: 'local'
    username: username
    password: password
  .then fakeFormSubmit.bind(null, username, password)

fakeFormSubmit = (username, password)->
  # Make the request as a good old html form not JS-generated
  # so that password managers can catch it and store its values.
  # Relies on form#browserLogin being in index.html from the start.
  # The server will make it redirect to '/', thus providing
  # to the need to reload the page
  $('#browserLogin').find('input[name=username]').val(username)
  $('#browserLogin').find('input[name=password]').val(password)
  $('#browserLogin').trigger('submit')

# will only be called by persona onlogin method
requestPersonaLogin = (assertion)->
  _.preq.post app.API.auth.login,
    strategy: 'browserid'
    assertion: assertion
    # needed on signup requests
    username: localStorage.getItem('username')
  .then -> window.location.reload()

emailConfirmationRequest = ->
  _.log 'sending emailConfirmationRequest'
  _.preq.post app.API.auth.emailConfirmation
