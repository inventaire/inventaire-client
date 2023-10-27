import { isEmail } from '#lib/boolean_tests'
import preq from '#lib/preq'
import forms_ from '#general/lib/forms'
import error_ from '#lib/error'
import { I18n } from '#user/lib/i18n'

async function verifyEmailAvailability (email) {
  if (email) await preq.get(app.API.auth.emailAvailability(email))
}

export default {
  pass (email, selector) {
    return forms_.pass({
      value: email,
      tests: emailTests,
      selector
    })
  },

  // verifies that the email isnt already in use
  verifyAvailability (email, selector) {
    return preq.get(app.API.auth.emailAvailability(email))
    .catch(err => {
      err.selector = selector
      throw err
    })
  }
}

const emailTests = {
  "it doesn't look like an email" (email) {
    return !isEmail(email)
  }
}

export function testEmail (email) {
  forms_.pass({
    value: email,
    tests: emailTests,
  })
}

export async function verifyEmail (email) {
  testEmail(email)
  await verifyEmailAvailability(email)
}

// Re-using verifyEmailAvailability but with the opposite expectaction:
// if it throws an error, the email is known and that's the desired result here
// thus the error is catched
export async function verifyKnownEmail (email) {
  try {
    await verifyEmailAvailability(email)
    throw error_.new(I18n('this email is unknown'), 401, { email })
  } catch (err) {
    if (err.statusCode !== 400) {
      throw err
    }
  }
}
