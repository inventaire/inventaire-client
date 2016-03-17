files_ = require 'lib/files'
imports = require '../../lib/imports'
ImportQueue = require './import_queue'
Candidates = require '../../collections/candidates'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  id: 'importLayout'
  template: require './templates/import'
  behaviors:
    Loading: {}

  regions:
    queue: '#queue'

  events:
    'change input[type=file]': 'getCsvFile'

  initialize: ->
    @candidates = new Candidates
    @listenToOnce @candidates, 'add', @showImportQueue.bind(@)

  showImportQueue: ->
    @queue.show new ImportQueue { collection: @candidates }

  getCsvFile: (e)->
    behaviorsPlugin.startLoading.call @
    source = e.currentTarget.id
    files_.parseFileEventAsText e, true, 'ISO-8859-1'
    # TODO: throw error on non-utf-8 encoding
    .then _.Log('csv files')
    .then imports[source]
    .then _.Log('parsed')
    .then @candidates.add.bind(@candidates)
    .then @scrollToQueue.bind(@)

  scrollToQueue: -> _.scrollTop @queue.$el
