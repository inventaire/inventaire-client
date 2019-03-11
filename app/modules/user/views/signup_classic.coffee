username_ = require 'modules/user/lib/username_tests'
email_ = require 'modules/user/lib/email_tests'
password_ = require 'modules/user/lib/password_tests'
forms_ = require 'modules/general/lib/forms'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
prepareRedirect = require '../lib/prepare_redirect'

module.exports = Marionette.LayoutView.extend
  className: 'authMenu signup'
  template: require './templates/signup_classic'
  behaviors:
    AlertBox: {}
    TogglePassword: {}
    Loading: {}

  ui:
    classicUsername: '#classicUsername'
    email: '#email'
    suggestionGroup: '#suggestionGroup'
    suggestion: '#suggestion'
    password: '#password'

  initialize: ->
    _.extend @, behaviorsPlugin
    @formAction = prepareRedirect.call @

  events:
    'blur #classicUsername': 'earlyVerifyClassicUsername'
    'blur #email': 'earlyVerifyEmail'
    # do not forms_.earlyVerify @, password as it is triggered
    # on "show password" clicks, which is boring
    # plus, it will presumably be verified next by click #validClassicSignup
    # 'blur #password': 'earlyVerifyPassword'
    'click #classicSignup': 'validClassicSignup'

  onShow:->
    @ui.classicUsername.focus()

  serializeData: ->
    passwordLabel: 'password'
    formAction: @formAction

  # CLASSIC
  validClassicSignup: ->
    @startLoading '#classicSignup'

    @verifyClassicUsername()
    .then @verifyEmail.bind(@)
    .then @verifyPassword.bind(@)
    .then @sendClassicSignupRequest.bind(@)
    .catch forms_.catchAlert.bind(null, @)

  verifyClassicUsername: -> @verifyUsername 'classicUsername'

  verifyEmail: ->
    email = @ui.email.val()
    email_.pass email, '#email'
    email_.verifyAvailability email, '#email'

  verifyPassword: -> password_.pass @ui.password.val(), '#finalAlertbox'

  sendClassicSignupRequest: ->
    app.request 'signup:classic',
      username: @ui.classicUsername.val()
      password: @ui.password.val()
      email: @ui.email.val()

  # COMMON
  verifyUsername: (name)->
    username = @ui[name].val()
    username_.verifyUsername(username, "##{name}")

  earlyVerifyClassicUsername: (e)->
    forms_.earlyVerify @, e, @verifyClassicUsername.bind(@)
  earlyVerifyEmail: (e)->
    forms_.earlyVerify @, e, @verifyEmail.bind(@)
  earlyVerifyPassword: (e)->
    forms_.earlyVerify @, e, @verifyPassword.bind(@)
