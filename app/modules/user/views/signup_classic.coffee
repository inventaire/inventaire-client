username_ = require 'modules/user/lib/username_tests'
email_ = require 'modules/user/lib/email_tests'
password_ = require 'modules/user/lib/password_tests'
forms_ = require 'modules/general/lib/forms'

module.exports = Backbone.Marionette.LayoutView.extend
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

  events:
    'blur #classicUsername': 'earlyVerifyClassicUsername'
    'blur #email': 'earlyVerifyEmail'
    # do not forms_.earlyVerify @, password as it is triggered
    # on "show password" clicks, which is boring
    # plus, it will presumably be verified next by click #validClassicSignup
    # 'blur #password': 'earlyVerifyPassword'
    'click #classicSignup': 'validClassicSignup'
    'click #suggestion': 'replaceEmail'


  # CLASSIC
  validClassicSignup: ->
    @verifyClassicUsername()
    .then @verifyEmail.bind(@)
    .then @verifyPassword.bind(@)
    .then @sendClassicSignupRequest.bind(@)
    .then -> window.location.reload()
    .catch forms_.catchAlert.bind(null, @)

  verifyClassicUsername: -> @verifyUsername 'classicUsername'
  verifyEmail: ->
    email = @ui.email.val()
    email_.pass email, '#email'
    email_.verifyAvailability email, "#email"
    .then email_.verifyExistance.bind(email_, email, '#email')
    .then @showSuggestion.bind(@)

  showSuggestion: (suggestion)->
    if suggestion?
      @ui.suggestion.text suggestion
      @ui.suggestionGroup.fadeIn()
      @suggestion = suggestion
    else _.log 'no suggestion'

  replaceEmail: ->
    @ui.email.val @suggestion
    @ui.suggestionGroup.fadeOut()

  verifyPassword: -> password_.pass @ui.password.val(), '#finalAlertbox'
  sendClassicSignupRequest: ->
    @$el.trigger 'loading', { selector: '#classicSignup' }
    _.preq.post app.API.auth.signup,
      username: @ui.classicUsername.val()
      password: @ui.password.val()
      email: @ui.email.val()
      strategy: 'local'

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
