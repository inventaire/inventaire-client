forms_ = require 'modules/general/lib/forms'

module.exports = username_ =
  pass: (username, selector)->
    forms_.pass
      value: username
      tests: usernameTests
      selector: selector

  verifyAvailability: (username, selector)->
    _.preq.get app.API.auth.usernameAvailability({ username })
    .catch (err)->
      err.selector = selector
      throw err

username_.verifyUsername = (username, selector)->
  _.preq.try username_.pass.bind(null, username, selector)
  .then username_.verifyAvailability.bind(null, username, selector)

usernameTests =
  'username should be 2 characters minimum' : (username)-> username.length < 2
  'username should be 20 characters maximum' : (username)-> username.length > 20
  "username can't contain space" : (username)-> /\s/.test username
  'username can only contain letters, figures or _' : (username)-> /\W/.test username
