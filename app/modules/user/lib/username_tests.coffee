forms_ = require 'modules/general/lib/forms'

module.exports = username_ =
  pass: (username, selector)->
    forms_.pass
      value: username
      tests: usernameTests
      selector: selector

  verifyAvailability: (username, selector)->
    _.preq.post(app.API.auth.usernameAvailability, {username: username})
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
