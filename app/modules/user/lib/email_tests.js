import { isEmail } from '#lib/boolean_tests'
import preq from '#lib/preq'
import forms_ from '#general/lib/forms'

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

export async function verifyEmail (email) {
  forms_.pass({
    value: email,
    tests: emailTests,
  })
  await verifyEmailAvailability(email)
}
