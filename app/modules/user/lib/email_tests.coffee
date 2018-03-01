forms_ = require 'modules/general/lib/forms'

module.exports =
  pass: (email, selector)->
    forms_.pass
      value: email
      tests: emailTests
      selector: selector

  # verifies that the email isnt already in use
  verifyAvailability: (email, selector)->
    _.preq.get app.API.auth.emailAvailability(email)
    .catch (err)->
      err.selector = selector
      throw err

emailTests =
  "it doesn't look like an email" : (email)->
    not _.isEmail(email)
