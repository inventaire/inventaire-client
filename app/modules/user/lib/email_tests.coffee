forms_ = require 'modules/general/lib/forms'

module.exports =
  pass: (email, selector)->
    forms_.pass
      value: email
      tests: emailTests
      selector: selector

  # checks that the email domain looks right
  verifyExistance: (email, selector)->
    _.preq.get app.API.services.emailValidation(email)
    .then (res)->
      _.log res, 'email verifyExistance res'
      unless res.is_valid
        err = new Error('invalid email')
        err.selector = selector
        throw err
      else return res.did_you_mean

  # verifies that the email isnt already in use
  verifyAvailability: (email, selector)->
    _.preq.get app.API.auth.emailAvailability(email)
    .catch (err)->
      err.selector = selector
      throw err


emailTests =
  "it doesn't look like an email" : (email)->
    not _.isEmail(email)