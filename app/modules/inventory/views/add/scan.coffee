zxing = require 'modules/inventory/lib/scanner/zxing'
embedded = require 'modules/inventory/lib/scanner/embedded'

module.exports = Marionette.ItemView.extend
  tagName: 'section'
  className: 'scan'
  template: require './templates/scan'
  serializeData: ->
    attrs = {}
    if _.isMobile then attrs.scanner = zxing.url
    return attrs

  behaviors:
    PreventDefault: {}

  events:
    'click #scanner': 'setAddModeScan'
    'click #startEmbeddedScanner': 'startEmbeddedScanner'

  setAddModeScan: -> app.execute 'last:add:mode:set', 'scan'

  startEmbeddedScanner: ->
    embedded()
    .then _.Log('embedded scanner')
    .catch _.Error('embedded scanner')
