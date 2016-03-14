scanner = require 'lib/scanner'

module.exports = Marionette.ItemView.extend
  template: require './templates/scan'
  serializeData: ->
    attrs = {}
    if _.isMobile then attrs.scanner = scanner.url
    return attrs

  behaviors:
    PreventDefault: {}

  events:
    'click #scanner': 'setAddModeScan'

  setAddModeScan: -> app.execute 'last:add:mode:set', 'scan'
