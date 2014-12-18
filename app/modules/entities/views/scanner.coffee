scanner = require 'lib/scanner'

module.exports = class ScannerButton extends Backbone.Marionette.ItemView
  template: require './templates/scanner'
  serializeData: ->
    url: scanner.url