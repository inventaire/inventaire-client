username_ = require 'modules/user/lib/username_tests'
forms_ = require 'modules/general/lib/forms'

module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/signup_persona'
  behaviors:
    AlertBox: {}

  serializeData: ->
    if @options.standalone
      standalone: true

  ui:
    personaUsername: '#personaUsername'
    personaPopup: '#personaPopup'
    personaSignup: '#personaSignup'

  events:
    'blur #personaUsername': 'earlyVerifyPersonaUsername'
    'click #personaSignup': 'validPersonaSignup'

  onShow:->
    if @options.standalone then @ui.personaUsername.focus()

  # PERSONA
  validPersonaSignup: ->
    @verifyPersonaUsername()
    .then @stashUsername
    .then @showPersonaLogin.bind(@)
    .catch forms_.catchAlert.bind(null, @)

  verifyPersonaUsername: -> @verifyUsername 'personaUsername'
  stashUsername: (res)->
    # stashing the username in localStorage for the
    # case when Persona comebacks from an email link
    # with no trace of the previous username
    localStorage.setItem 'username', res.username

  showPersonaLogin:->
    app.execute 'show:login:persona'

  earlyVerifyPersonaUsername: (e)->
    forms_.earlyVerify @, e, @verifyPersonaUsername.bind(@)

  # COMMON
  verifyUsername: (name)->
    username = @ui[name].val()
    username_.verifyUsername(username, "##{name}")
