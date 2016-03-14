files_ = require 'lib/files'
imports = require '../../lib/imports'

module.exports = Marionette.LayoutView.extend
  template: require './templates/import'

  events:
    'change input[type=file]': 'getCsvFile'

  getCsvFile: (e)->
    files_.parseFileEventAsText e, true, 'ISO-8859-1'
    # TODO: throw error on non-utf-8 encoding
    .then _.Log('csv files')
    .then imports.babelio
    .then _.Log('babelio parse')
