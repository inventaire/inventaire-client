import log_ from '#lib/loggers'
import preq from '#lib/preq'
import requestLogout from './request_logout.js'

export default function () {
  app.reqres.setHandlers({
    signup: requestSignup,
    login: requestLogin,
    'password:confirmation': passwordConfirmation,
    'password:update': passwordUpdate,
    'password:reset:request': passwordResetRequest,
    'email:confirmation:request': emailConfirmationRequest
  })

  app.commands.setHandlers({ logout: requestLogout })
}

const requestSignup = async function (options) {
  const { username, password } = options
  await preq.post(app.API.auth.signup, options)
  // not submitting email as there is no need for it
  // to be remembered by browsers
  formSubmit(username, password)
}

const passwordConfirmation = function (currentPassword) {
  // using the login route to verify the password validity
  const username = app.user.get('username')
  return login(username, currentPassword)
}

const requestLogin = async (username, password) => {
  await login(username, password)
  formSubmit(username, password)
}

const login = (username, password) => preq.post(app.API.auth.login, { username, password })

const passwordUpdate = async function (currentPassword, newPassword, selector) {
  const username = app.user.get('username')
  await preq.post(app.API.auth.updatePassword, {
    'current-password': currentPassword,
    'new-password': newPassword
  })
  if (selector != null) $(selector).trigger('check')
  formSubmit(username, newPassword)
}

const formSubmit = function (username, password) {
  // Make the request as a good old html form not JS-generated
  // so that password managers can catch it and store its values.
  // Relies on form#browserLogin being in index.html from the start.
  // The server will make it redirect to '/', thus providing
  // to the need to reload the page
  $('#browserLogin').find('input[name=username]').val(username)
  $('#browserLogin').find('input[name=password]').val(password)
  $('#browserLogin').trigger('submit')
}

const passwordResetRequest = email => preq.post(app.API.auth.resetPassword, { email })

const emailConfirmationRequest = function () {
  log_.info('sending emailConfirmationRequest')
  return preq.post(app.API.auth.emailConfirmation)
}
