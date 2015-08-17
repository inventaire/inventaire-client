loginPlugin = require 'modules/general/plugins/login'

module.exports = Marionette.ItemView.extend
  template: require './templates/call_to_connection'
  onShow: -> app.execute 'modal:open'
  serializeData: -> @options
  initialize: ->
    loginPlugin.call @
