import log_ from '#lib/loggers'
import preq from '#lib/preq'
import requestLogout from './request_logout.js'

export default function () {
  app.reqres.setHandlers({
    'password:confirmation': passwordConfirmation,
    'email:confirmation:request': emailConfirmationRequest
  })

  app.commands.setHandlers({ logout: requestLogout })
}

export async function requestSignup ({ username, email, password }) {
  await preq.post(app.API.auth.signup, { username, email, password })
}

const passwordConfirmation = function (currentPassword) {
  // using the login route to verify the password validity
  const username = app.user.get('username')
  return login(username, currentPassword)
}

export async function requestLogin ({ username, password }) {
  await login(username, password)
}

const login = (username, password) => preq.post(app.API.auth.login, { username, password })

export async function passwordUpdate ({ currentPassword, newPassword }) {
  await preq.post(app.API.auth.updatePassword, {
    'current-password': currentPassword,
    'new-password': newPassword
  })
}

export async function passwordResetRequest (email) {
  await preq.post(app.API.auth.resetPassword, { email })
}

const emailConfirmationRequest = function () {
  log_.info('sending emailConfirmationRequest')
  return preq.post(app.API.auth.emailConfirmation)
}
