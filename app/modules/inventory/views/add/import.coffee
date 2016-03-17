files_ = require 'lib/files'
importers = require '../../lib/importers'
dataValidator = require '../../lib/data_validator'
ImportQueue = require './import_queue'
Candidates = require '../../collections/candidates'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'

module.exports = Marionette.LayoutView.extend
  id: 'importLayout'
  template: require './templates/import'
  behaviors:
    Loading: {}
    AlertBox: {}

  regions:
    queue: '#queue'

  events:
    'change input[type=file]': 'getFile'
    'click input': 'hideAlertBox'

  initialize: ->
    @candidates = app.items.candidates ?= new Candidates

  onShow: ->
    # show the import queue if there were still candidates from last time
    if @candidates.length > 0 then @showImportQueue()
    else @listenToOnce @candidates, 'add', @showImportQueue.bind(@)

  serializeData: ->
    importers: importers

  showImportQueue: ->
    @queue.show new ImportQueue { collection: @candidates }

  getFile: (e)->
    behaviorsPlugin.startLoading.call @
    source = e.currentTarget.id
    { parse, encoding } = importers[source]

    files_.parseFileEventAsText e, true, encoding
    .then _.Log('uploaded file')
    .tap dataValidator.bind(null, source)
    .then parse
    .catch _.ErrorRethrow('parsing error')
    # add the selector to the rejected error
    # so that it can be catched by catchAlert
    .catch error_.Complete(".warning")
    .then _.Log('parsed')
    .then @candidates.add.bind(@candidates)
    .then @scrollToQueue.bind(@)
    .catch forms_.catchAlert.bind(null, @)

  scrollToQueue: -> _.scrollTop @queue.$el

  # passing the event to the AlertBox behavior
  hideAlertBox: -> @$el.trigger 'hideAlertBox'
