usernameTests = require 'modules/user/lib/username_tests'
passwordTests = require 'modules/user/lib/password_tests'

module.exports = class LoginStep1 extends Backbone.Marionette.ItemView
  className: 'book-bg'
  tagName: 'div'
  template: require './templates/login_step1'
  events:
    'click #classicLogin': 'classicLoginAttempt'
    'click #loginPersona': 'waitingForPersona'
    'click #createAccount': -> app.execute 'show:signup'
    'click #showPassword': 'togglePassword'

  behaviors:
    Loading: {}
    SuccessCheck: {}
    AlertBox: {}

  ui:
    username: '#username'
    password: '#password'
    showPassword: '#showPassword'

  initialize: ->
    @passwordShown = false

  classicLoginAttempt:->
    username = @ui.username.val()
    if _.isEmail(username) then @verifyPassword()
    else @verifyUsername(username)

  verifyUsername: (username)->
    usernameTests.validate
      username: username
      success: @verifyPassword.bind(@)
      view: @
      selector: '#username'

  verifyPassword: ->
    passwordTests.validate
      password: @ui.password.val()
      success: @classicLogin.bind(@)
      view: @

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
      message: _.i18n 'a popup should now open to let you verify your credentials'
      timeout: 'none'

  togglePassword: ->
    if @passwordShown then @passwordType 'password'
    else @passwordType 'text'

  passwordType: (type)->
    @ui.password.attr 'type', type
    @ui.showPassword.toggleClass 'active'
    @passwordShown = not @passwordShown
