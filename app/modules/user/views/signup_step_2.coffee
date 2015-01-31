module.exports = class SignupStep2 extends Backbone.Marionette.ItemView
  className: 'book-bg'
  template: require './templates/signup_step2'
  events:
    'click #loginPersona': 'waitingForPersona'

  behaviors:
    Loading: {}

  serializeData: ->
    username = localStorage.getItem('username')

    return attrs =
      back:
        classes: 'button'
        message: _.i18n 'edit username'
      welcome_username: _.i18n('welcome_username', {username: username})


  onShow: ->
    app.execute 'foundation:reload'
    if @options.triggerPersonaLogin
      @waitingForPersona()

  waitingForPersona:->
    $('#loginPersona').fadeOut()
    if _.isMobile
      message = _.i18n 'it should just take a few seconds now...'
    else
      message = _.i18n('a popup should now open to let you verify your credentials')
    app.execute 'persona:login'
    @$el.trigger 'loading',
      message: message
      timeout: 'none'
