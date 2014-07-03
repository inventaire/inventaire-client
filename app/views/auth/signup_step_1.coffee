SignupStep1Template = require 'views/auth/templates/signup_step1'
SignupStep2View = require 'views/auth/signup_step_2'

User = require 'models/user'

module.exports = LoginView = Backbone.View.extend
  el: '#authViews'
  template: SignupStep1Template
  initialize: ->
    @model = @model || new User
    @render()

  render: ->
    @$el.html @template(@model.attributes)
    @$el.foundation()
    return @

  events:
    'click #verifyUsername': 'verifyUsername'
    'click #backToSignupOrLoginView': 'backToSignupOrLoginView'

  verifyUsername: (e)->
    e.preventDefault()
    username = $('#username').val()
    $.post('/auth/username', {username: username})
    .then (res)=>
      @model.set('username', res.username)
      new SignupStep2View {model: @model}
    .fail(@unvalidUsername)

  unvalidUsername: (err)->
    errMessage = err.responseJSON.status_verbose || "invalid"
    $('#usernamePicker .alert-box').slideDown(200).prepend(errMessage)


  backToSignupOrLoginView: (e)->
    e.preventDefault()
    # callback scope issue: for some reason, I can't find a nice way not to require it here oO
    SignupOrLoginView = require "views/auth/signup_or_login_view"
    new SignupOrLoginView