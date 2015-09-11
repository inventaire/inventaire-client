requestLogout = require './request_logout'

module.exports = ->
  app.reqres.setHandlers
    'signup:classic': requestClassicSignup
    'login:classic': requestClassicLogin
    'password:confirmation': passwordConfirmation
    'password:update': passwordUpdate
    'password:reset:request': passwordResetRequest
    'login:persona': requestPersonaLogin
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
  _.preq.post app.API.auth.login,
    strategy: 'local'
    username: username
    password: password

passwordUpdate = (currentPassword, newPassword, selector)->
  username = app.user.get('username')
  _.preq.post app.API.auth.updatePassword,
    currentPassword: currentPassword
    newPassword: newPassword
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
  _.preq.post app.API.auth.resetPassword, { email: email }

# will only be called by persona onlogin method
requestPersonaLogin = (assertion)->
  _.preq.post app.API.auth.login,
    strategy: 'browserid'
    assertion: assertion
    # needed on signup requests
    username: localStorageProxy.getItem 'username'
  .then redirect

redirect = ->
  redir = app.request('route:querystring:get', 'redirect')
  if redir? then redir = "/#{redir}"
  else redir = '/'
  window.location.href = redir

# browserid login finds the redirect parameter in the querystring
# classic login finds the redirect parameter in form#browserLogin action
prepareLoginRedirect = (redir)->
  _.type redir, 'string'
  if redir[0] is '/' then redir = redir.slice(1)
  # for browserid login
  app.execute 'route:querystring:set', 'redirect', redir
  # for classic login
  [path, querystring] = $('#browserLogin')[0].action.split('?')
  query = _.parseQuery querystring
  # override redirect if one was already set
  query.redirect = redir
  $('#browserLogin')[0].action = _.buildPath path, query

emailConfirmationRequest = ->
  _.log 'sending emailConfirmationRequest'
  _.preq.post app.API.auth.emailConfirmation
