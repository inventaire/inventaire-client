import { API } from '#app/api/api'
import app from '#app/app'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import requestLogout from './request_logout.ts'

export default function () {
  app.commands.setHandlers({ logout: requestLogout })
}

export async function requestSignup ({ username, email, password }) {
  await preq.post(API.auth.signup, { username, email, password })
}

export function passwordConfirmation (currentPassword) {
  // using the login route to verify the password validity
  const username = app.user.username
  return login(username, currentPassword)
}

export async function requestLogin ({ username, password }) {
  await login(username, password)
}

const login = (username, password) => preq.post(API.auth.login, { username, password })

export async function passwordUpdate ({ currentPassword, newPassword }: { currentPassword?: string, newPassword: string }) {
  await preq.post(API.auth.updatePassword, {
    'current-password': currentPassword,
    'new-password': newPassword,
  })
}

export async function passwordResetRequest (email) {
  await preq.post(API.auth.resetPassword, { email })
}

export async function emailConfirmationRequest () {
  log_.info('sending emailConfirmationRequest')
  return preq.post(API.auth.emailConfirmation)
}
