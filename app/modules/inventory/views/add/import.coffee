files_ = require 'lib/files'
imports = require '../../lib/imports'
ImportQueue = require './import_queue'
Candidates = require '../../collections/candidates'

module.exports = Marionette.LayoutView.extend
  id: 'importLayout'
  template: require './templates/import'

  regions:
    queue: '#queue'

  events:
    'change input[type=file]': 'getCsvFile'

  initialize: ->
    @candidates = new Candidates
    @importQueueShown = false

    @listenTo @candidates, 'add', @showImportQueue.bind(@)

  showImportQueue: ->
    unless @importQueueShown
      @importQueueShown = true
      @queue.show new ImportQueue { collection: @candidates }

  getCsvFile: (e)->
    source = e.currentTarget.id
    files_.parseFileEventAsText e, true, 'ISO-8859-1'
    # TODO: throw error on non-utf-8 encoding
    .then _.Log('csv files')
    .then imports[source]
    .then _.Log('parsed')
    .then @candidates.add.bind(@candidates)
