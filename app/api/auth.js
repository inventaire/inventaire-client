{ action, actionPartial } = require('./endpoint')('auth')

module.exports =
  usernameAvailability: actionPartial 'username-availability', 'username'
  emailAvailability: actionPartial 'email-availability', 'email'

  signup: action 'signup'
  login: action 'login'
  logout: action 'logout'
  resetPassword: action 'reset-password'

  emailConfirmation: action 'email-confirmation'
  updatePassword: action 'update-password'
  # submit: defined directly in index.html form

  oauth:
    wikidata: action 'wikidata-oauth'
