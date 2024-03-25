import forms_ from '#general/lib/forms'

const passwordTests = {
  'password should be 8 characters minimum' (password = '') { return password.length < 8 },
  'password should be 5000 characters maximum' (password = '') { return password.length > 5000 },
}

export function testPassword (password) {
  return forms_.pass({
    value: password,
    tests: passwordTests,
  })
}

export default {
  pass: testPassword,
}
