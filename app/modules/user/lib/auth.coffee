requestLogout = require './request_logout'
{ parseQuery, buildPath } = require 'lib/location'

module.exports = ->
  app.reqres.setHandlers
    'signup:classic': requestClassicSignup
    'login:classic': requestClassicLogin
    'password:confirmation': passwordConfirmation
    'password:update': passwordUpdate
    'password:reset:request': passwordResetRequest
    'email:confirmation:request': emailConfirmationRequest

  app.commands.setHandlers
    'prepare:login:redirect': prepareLoginRedirect
    'logout': requestLogout

requestClassicSignup = (options)->
  { username, password } = options
  _.preq.post app.API.auth.signup, options
  # not submitting email as there is no need for it
  # to be remembered by browsers
  .then fakeFormSubmit.bind(null, username, password)

passwordConfirmation = (currentPassword)->
  # using the login route to verify the password validity
  username = app.user.get('username')
  classicLogin(username, currentPassword)

requestClassicLogin = (username, password)->
  classicLogin(username, password)
  .then fakeFormSubmit.bind(null, username, password)

classicLogin = (username, password)->
  _.preq.post app.API.auth.login, { username, password }

passwordUpdate = (currentPassword, newPassword, selector)->
  username = app.user.get('username')
  _.preq.post app.API.auth.updatePassword,
    'current-password': currentPassword
    'new-password': newPassword
  # updating the browser password
  .then -> if selector? then $(selector).trigger('check')
  .then fakeFormSubmit.bind(null, username, newPassword)

fakeFormSubmit = (username, password)->
  # Make the request as a good old html form not JS-generated
  # so that password managers can catch it and store its values.
  # Relies on form#browserLogin being in index.html from the start.
  # The server will make it redirect to '/', thus providing
  # to the need to reload the page
  $('#browserLogin').find('input[name=username]').val(username)
  $('#browserLogin').find('input[name=password]').val(password)
  $('#browserLogin').trigger('submit')

passwordResetRequest = (email)->
  _.preq.post app.API.auth.resetPassword, { email }

prepareLoginRedirect = (redir)->
  _.type redir, 'string'
  if redir[0] is '/' then redir = redir.slice(1)
  $browserLogin = $('#browserLogin')
  [ path, querystring ] = $browserLogin[0].action.split('?')
  query = parseQuery querystring
  # Override redirect if one was already set
  query.redirect = redir
  # Store the redirect parameter in form#browserLogin action
  $browserLogin[0].action = buildPath path, query

emailConfirmationRequest = ->
  _.log 'sending emailConfirmationRequest'
  _.preq.post app.API.auth.emailConfirmation
