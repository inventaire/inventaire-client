module.exports = class SignupStep2 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/user/templates/signup_step2'
  events:
    'click #loginPersona': 'waitingForPersona'

  behaviors:
    Loading: {}

  serializeData: ->
    back:
      classes: 'tiny button'

  onShow: ->
    app.execute 'foundation:reload'
    if @options.triggerPersonaLogin
      @waitingForPersona()

  waitingForPersona:->
    $('#loginPersona').fadeOut()
    app.execute 'persona:login'
    @$el.trigger 'loading',
      message: _.i18n('a popup should now open to let you verify your credentials')
