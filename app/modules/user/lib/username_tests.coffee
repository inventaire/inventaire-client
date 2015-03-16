fieldTests = require 'modules/general/lib/field_tests'

module.exports = username_ =
  pass: (username, selector)->
    fieldTests.pass
      value: username
      tests: usernameTests
      selector: selector

  validate: (options)->
    fieldTests.validate _.extend options,
      field: 'username'
      value: options.username
      tests: usernameTests

  # the view is passed as context
  # invalidUsername.call(@, err, selector)
  invalidUsername: (err, selector)->
    fieldTests.invalidValue @, err, 'username', selector

  verifyAvailability: (username, selector)->
    _.preq.post(app.API.auth.username, {username: username})
    .catch (err)->
      err.selector = selector
      throw err

username_.verifyUsername = (username, selector)->
  _.preq.start()
  .then username_.pass.bind(null, username, selector)
  .then username_.verifyAvailability.bind(null, username, selector)

usernameTests =
  "username can't be empty" : (username)->
    username is ''

  'username should be 20 characters maximum' : (username)->
    username.length > 20

  "username can't contain space" : (username)->
    /\s/.test username

  'username can only contain letters, figures or _' : (username)->
    /\W/.test username
