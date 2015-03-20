username_ = require 'modules/user/lib/username_tests'
email_ = require 'modules/user/lib/email_tests'
password_ = require 'modules/user/lib/password_tests'
forms_ = require 'modules/general/lib/forms'

module.exports = Backbone.Marionette.ItemView.extend
  className: 'book-bg'
  tagName: 'div'
  template: require './templates/login'
  events:
    'blur #username': 'earlyVerifyUsername'
    'click #classicLogin': 'classicLoginAttempt'
    'click #personaLogin': 'showPersonaLogin'
    'click #createAccount': -> app.execute 'show:signup'

  behaviors:
    Loading: {}
    SuccessCheck: {}
    AlertBox: {}
    TogglePassword: {}

  ui:
    username: '#username'
    password: '#password'

  onShow:-> @ui.username.focus()

  classicLoginAttempt:->
    _.preq.start()
    .then @verifyUsername.bind(@)
    .then @verifyPassword.bind(@)
    .then @classicLogin.bind(@)
    .catch forms_.catchAlert.bind(null, @)

  verifyUsername: (username)->
    username = @ui.username.val()
    unless _.isEmail(username)
      username_.pass username, '#username'

  earlyVerifyUsername: (e)->
    forms_.earlyVerify @, e, @verifyUsername.bind(@)

  verifyPassword: ->
    password_.pass @ui.password.val(), '#finalAlertbox'

  classicLogin:->
    username = @ui.username.val()
    password = @ui.password.val()
    app.request 'login:classic', username, password
    .catch @loginError.bind(@)

    @$el.trigger 'loading', { selector: '#classicLogin' }

  loginError: (err)->
    @$el.trigger 'stopLoading'
    if err.status is 401 then @alertUsernameOrPasswordError()
    else _.error err, 'classic login err'

  alertUsernameOrPasswordError: ->
    @$el.trigger 'alert',
      message: _.i18n @getErrMessage()

  getErrMessage: ->
    username = @ui.username.val()
    if _.isEmail(username) then 'email or password is incorrect'
    else 'username or password is incorrect'

  showPersonaLogin:->
    app.execute 'show:login:persona'
