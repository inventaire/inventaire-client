events =
  'click #signupRequest': 'showSignup'
  'click #loginRequest': 'showLogin'

handlers =
  showSignup: -> app.execute 'show:signup'
  showLogin:-> app.execute 'show:login'

module.exports = _.BasicPlugin events, handlers
