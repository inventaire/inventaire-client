import requestLogout from './request_logout'
import { parseQuery, buildPath } from 'lib/location'

export default function () {
  app.reqres.setHandlers({
    'signup:classic': requestClassicSignup,
    'login:classic': requestClassicLogin,
    'password:confirmation': passwordConfirmation,
    'password:update': passwordUpdate,
    'password:reset:request': passwordResetRequest,
    'email:confirmation:request': emailConfirmationRequest
  })

  return app.commands.setHandlers({ logout: requestLogout })
};

const requestClassicSignup = function (options) {
  const { username, password } = options
  return _.preq.post(app.API.auth.signup, options)
  // not submitting email as there is no need for it
  // to be remembered by browsers
  .then(formSubmit.bind(null, username, password))
}

const passwordConfirmation = function (currentPassword) {
  // using the login route to verify the password validity
  const username = app.user.get('username')
  return classicLogin(username, currentPassword)
}

const requestClassicLogin = (username, password) => classicLogin(username, password)
.then(formSubmit.bind(null, username, password))

const classicLogin = (username, password) => _.preq.post(app.API.auth.login, { username, password })

const passwordUpdate = function (currentPassword, newPassword, selector) {
  const username = app.user.get('username')
  return _.preq.post(app.API.auth.updatePassword, {
    'current-password': currentPassword,
    'new-password': newPassword
  }).then(() => { if (selector != null) { return $(selector).trigger('check') } })
  .then(formSubmit.bind(null, username, newPassword))
}

const formSubmit = function (username, password) {
  // Make the request as a good old html form not JS-generated
  // so that password managers can catch it and store its values.
  // Relies on form#browserLogin being in index.html from the start.
  // The server will make it redirect to '/', thus providing
  // to the need to reload the page
  $('#browserLogin').find('input[name=username]').val(username)
  $('#browserLogin').find('input[name=password]').val(password)
  return $('#browserLogin').trigger('submit')
}

const passwordResetRequest = email => _.preq.post(app.API.auth.resetPassword, { email })

const emailConfirmationRequest = function () {
  _.log('sending emailConfirmationRequest')
  return _.preq.post(app.API.auth.emailConfirmation)
}
