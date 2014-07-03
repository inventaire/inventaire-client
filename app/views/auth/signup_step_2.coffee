SignupStep2Template = require 'views/auth/templates/signup_step2'

module.exports = SignupStep2View = Backbone.View.extend
  el: '#authViews'
  template: SignupStep2Template
  initialize: ->
    @render()
    @$el.find('.fa-check-circle').slideDown()

  render: ->
    @$el.html @template(@model.attributes)
    @$el.foundation()
    return @

  events:
    'click #backToStepOne': 'backToStepOne'

  backToStepOne: (e)->
    e.preventDefault()
    # callback scope issue: for some reason, I can't find a nice way not to require it here oO
    SignupStep1View = require 'views/auth/signup_step_1'
    new SignupStep1View {model: @model}