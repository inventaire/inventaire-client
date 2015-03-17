forms_ = require 'modules/general/lib/forms'

module.exports =
  pass: (password, selector)->
    forms_.pass
      value: password
      tests: passwordTests
      selector: selector

passwordTests =
  'password should be 8 characters minimum' : (password)->
    password.length < 8

  'password should be 60 characters maximum' : (password)->
    password.length > 60