behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  className: 'authMenu login'
  template: require './templates/login_persona'
  events:
    'click #personaLogin': 'triggerPersonaLoggin'

  behaviors:
    Loading: {}

  initialize: -> _.extend @, behaviorsPlugin

  onShow: ->
    # automatically triggers login
    @triggerPersonaLoggin()

  triggerPersonaLoggin:->
    app.execute 'persona:login:request'
    @startLoading
      message: _.i18n 'waiting_for_persona'
      timeout: 'none'
      selector: '#personaButtonGroup'
