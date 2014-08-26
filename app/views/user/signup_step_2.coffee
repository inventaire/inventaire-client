module.exports = class SignupStep2 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/user/templates/signup_step2'
  events:
    'click #loginPersona': 'waitingForPersona'
    'click #backToStepOne': 'backToStepOne'
  behaviors:
    Loading: {}

  backToStepOne: (e)->
    app.layout.main.show new app.View.Signup.Step1 {model: app.user}

  onShow: -> app.execute 'foundation:reload'

  waitingForPersona:->
    app.execute 'persona:login'
    @$el.trigger 'loading',
      message: _.i18n('a popup should now open to let you verify your credentials')