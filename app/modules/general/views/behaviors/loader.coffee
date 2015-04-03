loadingPlugin = require 'modules/general/plugins/loading'

module.exports = Loader = Backbone.Marionette.ItemView.extend
  template: require './templates/loader'
  behaviors:
    Loading: {}

  onShow: -> loadingPlugin.startLoading.call(@)