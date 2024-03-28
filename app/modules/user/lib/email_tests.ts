import app from '#app/app'
import { pass } from '#general/lib/forms'
import { isEmail } from '#lib/boolean_tests'
import preq from '#lib/preq'

async function verifyEmailAvailability (email) {
  if (email) await preq.get(app.API.auth.emailAvailability(email))
}

export default {
  pass (email, selector) {
    return pass({
      value: email,
      tests: emailTests,
      selector,
    })
  },

  // verifies that the email isnt already in use
  verifyAvailability (email, selector) {
    return preq.get(app.API.auth.emailAvailability(email))
    .catch(err => {
      err.selector = selector
      throw err
    })
  },
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
  await verifyEmailAvailability(email)
}
