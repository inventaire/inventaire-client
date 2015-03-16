fieldTests = require 'modules/general/lib/field_tests'

module.exports =
  pass: (email, selector)->
    fieldTests.pass
      value: email
      tests: emailTests
      selector: selector

  verifyExistance: (email, selector)->
    _.preq.get app.API.services.emailValidation(email)
    .then (res)->
      _.log res, 'email verifyExistance res'
      unless res.is_valid
        err = new Error('invalid email')
        err.selector = selector
        throw err
      else return res.did_you_mean

  verifyAvailability: (email, selector)->
    _.preq.post(app.API.auth.email, {email: email})
    .catch (err)->
      err.selector = selector
      throw err


emailTests =
  "it doesn't look like an email" : (email)->
    not _.isEmail(email)