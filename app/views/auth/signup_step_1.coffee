SignupStep1Template = require 'views/auth/templates/signup_step1'
SignupStep2View = require 'views/auth/signup_step_2'

User = require 'models/user'

module.exports = SignupStep1View = Backbone.View.extend
  tagName: 'div'
  template: SignupStep1Template
  initialize: ->
    @model = @model || new User
    @render()
    $('#authViews').html @$el

  render: ->
    @$el.html @template(@model.attributes)
    @$el.foundation()
    return @

  events:
    'click #verifyUsername': 'verifyUsername'
    'click #backToSignupOrLoginView': 'backToSignupOrLoginView'

  verifyUsername: (e)->
    e.preventDefault()
    console.log 'verify'
    username = $('#username').val()
    $.post('/auth/username', {username: username})
    .then (res)=>
      @model.set('username', window.username = res.username)
      @$el.find('.fa-check-circle').slideDown(300)
      cb = ()=>new SignupStep2View {model: @model}
      setTimeout(cb, 500)
    .fail(@unvalidUsername)

  unvalidUsername: (err)->
    errMessage = err.responseJSON.status_verbose || "invalid"
    $('#usernamePicker .alert-box').slideDown(200).prepend(errMessage)


  backToSignupOrLoginView: (e)->
    e.preventDefault()
    # callback scope issue: for some reason, I can't find a nice way not to require it here oO
    SignupOrLoginView = require "views/auth/signup_or_login_view"
    new SignupOrLoginView