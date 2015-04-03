behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Loader = Backbone.Marionette.ItemView.extend
  template: require './templates/loader'
  behaviors:
    Loading: {}

  onShow: -> behaviorsPlugin.startLoading.call(@)
