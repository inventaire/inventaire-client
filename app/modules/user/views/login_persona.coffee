module.exports = Backbone.Marionette.ItemView.extend
  className: 'book-bg'
  tagName: 'div'
  template: require './templates/login_persona'
  events:
    'click #personaLogin': 'triggerPersonaLoggin'

  behaviors:
    Loading: {}

  onShow: ->
    # automatically triggers login
    @triggerPersonaLoggin()

  triggerPersonaLoggin:->
    app.execute 'persona:login:request'
    @$el.trigger 'loading',
      message: _.i18n 'waiting_for_persona'
      timeout: 'none'
      selector: '#personaButtonGroup'
