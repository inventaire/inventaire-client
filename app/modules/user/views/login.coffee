username_ = require 'modules/user/lib/username_tests'
password_ = require 'modules/user/lib/password_tests'
forms_ = require 'modules/general/lib/forms'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  className: 'authMenu login'
  template: require './templates/login'
  events:
    'blur #username': 'earlyVerifyUsername'
    'click #classicLogin': 'classicLoginAttempt'
    'click #createAccount': -> app.execute 'show:signup'
    'click #forgotPassword': -> app.execute 'show:forgot:password'

  behaviors:
    Loading: {}
    SuccessCheck: {}
    AlertBox: {}
    TogglePassword: {}

  ui:
    username: '#username'
    password: '#password'

  initialize: ->
    _.extend @, behaviorsPlugin

    redirect = app.request 'querystring:get', 'redirect'
    if _.isNonEmptyString redirect
      app.execute 'prepare:login:redirect', redirect

  onShow:-> @ui.username.focus()

  serializeData: ->
    passwordLabel: 'password'

  classicLoginAttempt:->
    _.preq.try @verifyUsername.bind(@)
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

    @startLoading '#classicLogin'

  loginError: (err)->
    @stopLoading()
    if err.statusCode is 401 then @alert @getErrMessage()
    else _.error err, 'classic login err'

  getErrMessage: ->
    username = @ui.username.val()
    if _.isEmail(username) then 'email or password is incorrect'
    else 'username or password is incorrect'
