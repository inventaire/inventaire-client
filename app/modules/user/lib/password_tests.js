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

const passwordTests = {
  'password should be 8 characters minimum' (password) { return password.length < 8 },
  'password should be 5000 characters maximum' (password) { return password.length > 5000 }
}
