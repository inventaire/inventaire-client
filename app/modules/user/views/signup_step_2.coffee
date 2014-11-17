module.exports = class SignupStep2 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require './templates/signup_step2'
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
    if _.isMobile()
      message = _.i18n 'it should just take a few seconds now...'
    else
      message = _.i18n('a popup should now open to let you verify your credentials')
    app.execute 'persona:login'
    @$el.trigger 'loading',
      message: message
      timeout: 'none'
