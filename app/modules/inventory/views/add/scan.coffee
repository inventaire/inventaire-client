embedded_ = require 'modules/inventory/lib/scanner/embedded'

module.exports = Marionette.ItemView.extend
  className: 'scan'
  template: require './templates/scan'
  initialize: ->
    if window.hasVideoInput then embedded_.prepare()

  serializeData: ->
    hasVideoInput: window.hasVideoInput
    doesntSupportEnumerateDevices: window.doesntSupportEnumerateDevices

  events:
    'click #embeddedScanner': 'startEmbeddedScanner'

  startEmbeddedScanner: -> app.execute 'show:scanner:embedded'
