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
    'change input[type=file]': 'getCsvFile'
    'click input': 'hideAlertBox'

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
    .then _.Log('imported file')
    .tap dataValidator.bind(null, source)
    .then importers[source]
    .catch error_.Complete(".warning")
    .then _.Log('parsed')
    .then @candidates.add.bind(@candidates)
    .then @scrollToQueue.bind(@)
    # add the selector to the rejected error
    # so that an alert can be shown under the right source
    .catch forms_.catchAlert.bind(null, @)

  scrollToQueue: -> _.scrollTop @queue.$el

  # passing the event to the AlertBox behavior
  hideAlertBox: -> @$el.trigger 'hideAlertBox'
