module.exports = class LoginStep1 extends Backbone.Marionette.ItemView
  className: 'book-bg'
  tagName: 'div'
  template: require './templates/login_step1'
  events:
    'click #classicLogin': 'classicLogin'
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

  onShow: ->
    if @options.triggerPersonaLogin
      @waitingForPersona()

  classicLogin:->
    username = @ui.username.val()
    password = @ui.password.val()
    app.request 'login:classic', username, password
    .catch @loginError.bind(@)

  loginError: (err)->
    if err.status is 401
      @alertUsernameOrPasswordError()
    else
      _.error err, 'classic login err'

  alertUsernameOrPasswordError: ->
    @$el.trigger 'alert',
      message: _.i18n 'username or password is invalid'


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
