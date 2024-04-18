import { API } from '#app/api/api'
import preq from '#app/lib/preq'
import { Username } from '#app/lib/regex'
import { pass } from '#general/lib/forms'

async function verifyUsernameAvailability (username) {
  await preq.get(API.auth.usernameAvailability(username))
}

export function passUsernameTests (username) {
  return pass({
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
  'username can only contain letters, figures or _' (username) { return !Username.test(username) },
}
