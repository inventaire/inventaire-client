module.exports = class SignupStep2 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/auth/templates/signup_step2'
  events:
    'click #loginPersona': 'loginPersona'
    'click #backToStepOne': 'backToStepOne'

  loginPersona: ()->
    app.vent.trigger 'persona:request'

  backToStepOne: (e)->
    e.preventDefault()
    app.layout.modal.show new app.View.Signup.Step1 {model: app.user}