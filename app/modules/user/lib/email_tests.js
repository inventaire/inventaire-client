import { isEmail } from 'lib/boolean_tests'
import preq from 'lib/preq'
import forms_ from 'modules/general/lib/forms'

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
