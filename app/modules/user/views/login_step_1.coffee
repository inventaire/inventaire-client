module.exports = class LoginStep1 extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require './templates/login_step1'
  events:
    'click #loginPersona': 'waitingForPersona'
    'click #createAccount': -> app.execute 'show:signup'
  behaviors:
    Loading: {}

  onShow: ->
    if @options.triggerPersonaLogin
      @waitingForPersona()
    app.execute 'bg:book:toggle'

  onDestroy: ->  app.execute 'bg:book:toggle'

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