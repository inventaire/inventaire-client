events =
  'click #signupRequest': 'showSignup'
  'click #loginRequest': 'showLogin'

handlers =
  showSignup: -> app.execute 'show:signup:redirect'
  showLogin:-> app.execute 'show:login:redirect'

module.exports = _.BasicPlugin events, handlers
