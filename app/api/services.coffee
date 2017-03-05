{ actionPartial } = require('./endpoint')('services')

module.exports =
  emailValidation: actionPartial 'email-validation', 'email'
