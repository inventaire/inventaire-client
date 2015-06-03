behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  template: require './templates/loader'
  behaviors:
    Loading: {}

  onShow: -> behaviorsPlugin.startLoading.call(@)
