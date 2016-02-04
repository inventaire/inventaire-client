loginPlugin = require 'modules/general/plugins/login'
{ banner } = require('lib/urls').images

module.exports = Marionette.ItemView.extend
  template: require './templates/call_to_connection'
  behaviors:
    General: {}
  onShow: -> app.execute 'modal:open'
  serializeData: ->
    _.extend @options,
      banner: banner
  initialize: ->
    loginPlugin.call @
