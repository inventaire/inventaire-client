username_ = require 'modules/user/lib/username_tests'
email_ = require 'modules/user/lib/email_tests'
password_ = require 'modules/user/lib/password_tests'
fieldTests = require 'modules/general/lib/field_tests'

module.exports = class LoginStep1 extends Backbone.Marionette.ItemView
  className: 'book-bg'
  tagName: 'div'
  template: require './templates/login_step1'
  events:
    'click #classicLogin': 'classicLoginAttempt'
    'click #loginPersona': 'waitingForPersona'
    'click #createAccount': -> app.execute 'show:signup'

  behaviors:
    Loading: {}
    SuccessCheck: {}
    AlertBox: {}
    TogglePassword: {}

  ui:
    username: '#username'
    password: '#password'

  classicLoginAttempt:->
    _.preq.start()
    .then @verifyUsername.bind(@)
    .then @verifyPassword.bind(@)
    .then @classicLogin.bind(@)
    .catch @catchFail.bind(@)

  verifyUsername: (username)->
    username = @ui.username.val()
    unless _.isEmail(username)
      username_.pass username, '#username'

  catchFail: (err)->
    if err.selector? then @alert(err)
    else _.error err, 'signup catchFail err'

  alert: (err)->
    fieldTests.invalidValue @, err, err.selector

  verifyPassword: ->
    password_.pass @ui.password.val(), '#finalAlertbox'

  classicLogin:->
    username = @ui.username.val()
    password = @ui.password.val()
    app.request 'login:classic', username, password
    .catch @loginError.bind(@)

  loginError: (err)->
    if err.status is 401 then @alertUsernameOrPasswordError()
    else _.error err, 'classic login err'

  alertUsernameOrPasswordError: ->
    @$el.trigger 'alert',
      message: _.i18n @getErrMessage()

  getErrMessage: ->
    username = @ui.username.val()
    if _.isEmail(username) then 'email or password is incorrect'
    else 'username or password is incorrect'

  waitingForPersona:->
    $('#loginPersona').fadeOut()
    app.execute 'login:persona'
    @$el.trigger 'loading',
      message: _.i18n 'waiting_for_persona'
      timeout: 'none'
