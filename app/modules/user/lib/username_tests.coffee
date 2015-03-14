fieldTests = require 'modules/general/lib/field_tests'

module.exports =
  validate: (options)->
    fieldTests.validate _.extend options,
      field: 'username'
      value: options.username
      tests: usernameTests

  invalidUsername: (err, selector)->
    fieldTests.invalidValue @, err, 'username', selector

usernameTests =
  "username can't be empty" : (username)->
    username is ''

  'username should be 20 characters maximum' : (username)->
    username.length > 20

  "username can't contain space" : (username)->
    /\s/.test username

  'username can only contain letters, figures or _' : (username)->
    /\W/.test username
