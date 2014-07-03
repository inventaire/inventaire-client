SignupLoginTemplate = require 'views/templates/signup_login'
SignupStep2View = require 'views/signup_step_2'

User = require 'models/user'

module.exports = LoginView = Backbone.View.extend
  el: '#loginModal'
  template: SignupLoginTemplate
  initialize: ->
    @model = @model || new User
    @render()

  render: ->
    @$el.html @template(@model.attributes)

  events:
    'click #verifyUsername': 'verifyUsername'

  verifyUsername: (e)->
    e.preventDefault()
    username = $('#username').val()
    console.log "verify #{username} (please)"
    $.post('/auth/username', {username: username})
    .then (res)=>
      @model.set('username', res.username)
      step2 = new SignupStep2View {model: @model}
    .fail(@unvalidUsername)



  # validUsername: (res)=>
  #   console.dir @
  #   @model.set('username', res.username)
  #   console.dir @model
  #   # step2 = new SignupStep2View {model: @model}

  unvalidUsername: (err)->
    errMessage = err.responseJSON.status_verbose || "invalid"
    $('#usernamePicker .alert-box').slideDown(200).prepend(errMessage)