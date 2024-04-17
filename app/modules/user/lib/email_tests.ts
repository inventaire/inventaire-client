import app from '#app/app'
import { isEmail } from '#app/lib/boolean_tests'
import preq from '#app/lib/preq'
import { pass } from '#general/lib/forms'
import type { Email } from '#server/types/user'

// Verifies that the email isnt already in use
export function verifyEmailAvailability (email: Email) {
  return preq.get(app.API.auth.emailAvailability(email))
}

const emailTests = {
  "it doesn't look like an email" (email) {
    return !isEmail(email)
  },
}

export function testEmail (email) {
  pass({
    value: email,
    tests: emailTests,
  })
}

export async function verifyEmail (email) {
  testEmail(email)
  if (email) await verifyEmailAvailability(email)
}
