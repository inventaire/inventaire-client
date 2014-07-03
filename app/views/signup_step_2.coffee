SignupStep2Template = require 'views/templates/signup_step2'



module.exports = SignupStep2View = Backbone.View.extend
  el: '#loginModal'
  template: SignupStep2Template
  initialize: ->
    console.dir @model
    @render()
    @$el.find('.fa-check-circle').slideDown()

  render: ->
    @$el.html @template(@model.attributes)
    return @

  events:
    'click #backToStepOne': 'backToStepOne'

  backToStepOne: (e)->
    e.preventDefault()
    # callback scope issue: can't find a nice way not to require it here :/
    LoginView = require "views/login_view"
    loginModal = new LoginView {model: @model}