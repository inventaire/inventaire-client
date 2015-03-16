username_ = require 'modules/user/lib/username_tests'
email_ = require 'modules/user/lib/email_tests'
password_ = require 'modules/user/lib/password_tests'
fieldTests = require 'modules/general/lib/field_tests'

module.exports = class SignupStep1 extends Backbone.Marionette.ItemView
  className: 'book-bg'
  template: require './templates/signup_step1'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    TogglePassword: {}
    Loading: {}

  ui:
    classicUsername: '#classicUsername'
    personaUsername: '#personaUsername'
    email: '#email'
    suggestionGroup: '#suggestionGroup'
    suggestion: '#suggestion'
    password: '#password'
    personaPopup: '#personaPopup'
    personaSignup: '#personaSignup'

  onShow: ->
    app.execute 'foundation:reload'

  serializeData:->
    smallscreen: _.smallScreen()

  events:
    'blur #classicUsername': (e)-> @earlyVerify e, @verifyClassicUsername.bind(@)
    'blur #personaUsername': (e)-> @earlyVerify e, @verifyPersonaUsername.bind(@)
    'blur #email':  (e)-> @earlyVerify e, @verifyEmail.bind(@)
    # do not earlyVerify password as it is triggered
    # on "show password" clicks, which is boring
    # plus, it will presumably be verified next by click #validClassicSignup
    # 'blur #password':  (e)-> @earlyVerify e, @verifyPassword.bind(@)
    'click #classicSignup': 'validClassicSignup'
    'click #personaSignup': 'validPersonaSignup'
    'click #suggestion': 'replaceEmail'


  # CLASSIC
  validClassicSignup: ->
    @verifyClassicUsername()
    .then @verifyEmail.bind(@)
    .then @verifyPassword.bind(@)
    .then @sendClassicSignupRequest.bind(@)
    .then -> window.location.reload()
    .catch @catchFail.bind(@)

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
    _.preq.post app.API.auth.signup,
      username: @ui.classicUsername.val()
      password: @ui.password.val()
      email: @ui.email.val()
      strategy: 'local'

  # PERSONA
  validPersonaSignup: ->
    @verifyPersonaUsername()
    .then @stashUsername
    .then @waitingForPersona.bind(@)
    .catch @catchFail.bind(@)

  verifyPersonaUsername: -> @verifyUsername 'personaUsername'
  stashUsername: (res)->
    # stashing the username in localStorage for the
    # case when Persona comebacks from an email link
    # with no trace of the previous username
    localStorage.setItem 'username', res.username

  waitingForPersona:->
    @ui.personaSignup.fadeOut()
    # @ui.personaPopup.fadeIn()
    app.execute 'login:persona'
    @$el.trigger 'loading',
      message: _.i18n 'waiting_for_persona'
      timeout: 'none'

  # COMMON
  verifyUsername: (name)->
    username = @ui[name].val()
    username_.verifyUsername(username, "##{name}")

  catchFail: (err)->
    if err.selector? then @alert(err)
    else _.error err, 'signup catchFail err'

  alert: (err)->
    fieldTests.invalidValue @, err, err.selector

  # verify field value before the form is submitted
  earlyVerify: (e, verificator)->
    # dont show alert empty fields as it feels a bit agressive
    unless $(e.target)?.val() is ''
      _.preq.start()
      .then verificator
      .catch @catchFail.bind(@)
