/* eslint-disable
    import/no-duplicates,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import forms_ from 'modules/general/lib/forms'

export default {
  pass (password, selector) {
    return forms_.pass({
      value: password,
      tests: passwordTests,
      selector
    })
  }
}

var passwordTests = {
  'password should be 8 characters minimum' (password) { return password.length < 8 },
  'password should be 5000 characters maximum' (password) { return password.length > 5000 }
}
