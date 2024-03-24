import preq from '#lib/preq'
import forms_ from '#general/lib/forms'
import { Username } from '#lib/regex'

async function verifyUsernameAvailability (username) {
  await preq.get(app.API.auth.usernameAvailability(username))
}

export function passUsernameTests (username) {
  return forms_.pass({
    value: username,
    tests: usernameTests,
  })
}

export async function verifyUsername (username) {
  passUsernameTests(username)
  await verifyUsernameAvailability(username)
}

const usernameTests = {
  'username should be 2 characters minimum' (username) { return username.length < 2 },
  'username should be 20 characters maximum' (username) { return username.length > 20 },
  "username can't contain space" (username) { return /\s/.test(username) },
  'username can only contain letters, figures or _' (username) { return !Username.test(username) }
}
