files_ = require 'lib/files'
importers = require '../../lib/importers'
dataValidator = require '../../lib/data_validator'
ImportQueue = require './import_queue'
Candidates = require '../../collections/candidates'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
papaparse = require('lib/get_assets')('papaparse')

importLib = '../../lib/import'
fetchEntitiesSequentially = require "#{importLib}/fetch_entities_sequentially"
extractIsbns = require "#{importLib}/extract_isbns"
getCandidatesFromEntitiesDocs = require "#{importLib}/get_candidates_from_entities_docs"

candidates = null

module.exports = Marionette.LayoutView.extend
  id: 'importLayout'
  template: require './templates/import'
  behaviors:
    AlertBox: {}
    Loading: {}
    PreventDefault: {}
    SuccessCheck: {}

  regions:
    queue: '#queue'

  ui:
    addedItems: '#addedItems'
    isbnsImporter: '#isbnsImporter'
    isbnsImporterTextarea: '#isbnsImporter textarea'
    isbnsImporterWrapper: '#isbnsImporterWrapper'
    separator: '.separator'
    importersWrapper: '#importersWrapper'
    isbnsImporterStatus: '#isbnsImporterStatus'

  events:
    'change input[type=file]': 'getFile'
    'click input': 'hideAlertBox'
    'click #addedItems': 'showMainUserInventory'
    'keyup #isbnsImporter textarea': 'displayImportButton'

  childEvents:
    'import:done': 'onImportDone'

  initialize: ->
    papaparse.prepare()
    @candidates = candidates or= new Candidates

  onShow: ->
    # show the import queue if there were still candidates from last time
    @showImportQueueUnlessEmpty()
    @listenTo @candidates, 'reset', @hideImportQueueIfEmpty.bind(@)

  serializeData: ->
    importers: importers
    inventory: app.user.get('pathname')

  showImportQueueUnlessEmpty: ->
    if @candidates.length > 0
      # slide down in case @queue.$el was previously hidden
      # by hideImportQueueIfEmpty
      @queue.$el.slideDown()
      if not @queue.hasView()
        @queue.show new ImportQueue { collection: @candidates }

      _.scrollTop @queue.$el

  hideImportQueueIfEmpty: ->
    if @candidates.length is 0 then @queue.$el.slideUp()

  getFile: (e)->
    behaviorsPlugin.startLoading.call @, '.loading-queue'
    source = e.currentTarget.id
    { parse, encoding } = importers[source]

    Promise.all [
      files_.parseFileEventAsText e, true, encoding
      papaparse.get()
    ]
    # We only need the result from the file
    .spread _.Log('uploaded file')
    .tap dataValidator.bind(null, source)
    .then parse
    .catch _.ErrorRethrow('parsing error')
    # add the selector to the rejected error
    # so that it can be catched by catchAlert
    .catch error_.Complete('.warning')
    .then _.Log('parsed')
    .then @candidates.add.bind(@candidates)
    .tap => behaviorsPlugin.stopLoading.call @, '.loading-queue'
    .then @showImportQueueUnlessEmpty.bind(@)
    # .then @scrollToQueue.bind(@)
    .catch forms_.catchAlert.bind(null, @)

  # passing the event to the AlertBox behavior
  hideAlertBox: -> @$el.trigger 'hideAlertBox'

  onImportDone: ->
    @hideImportQueueIfEmpty()
    @$el.trigger 'check'
    # show the message once import_queue success check is over
    setTimeout @ui.addedItems.fadeIn.bind(@ui.addedItems), 700

  showMainUserInventory: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:inventory:main:user'

  displayImportButton: ->
    @lazyDisplayImportButton or= _.debounce @_displayImportButton.bind(@), 500
    @lazyDisplayImportButton()

  _displayImportButton: ->
    text = @ui.isbnsImporterTextarea.val()
    unless _.isNonEmptyString(text) then return

    isbnsData = extractIsbns text
    _.log isbnsData, 'isbns'

    if isbnsData.length is 0 then return

    @ui.separator.hide()
    @ui.importersWrapper.hide()
    @ui.isbnsImporterStatus.text _.i18n('ISBNs found:') + ' ' + isbnsData.length
    @ui.importersWrapper.find('.warning').show()

    fetchEntitiesSequentially isbnsData
    .then @displayResults.bind(@)

  displayResults: (data)->
    { results, isbnsIndex } = data
    newCandidates = getCandidatesFromEntitiesDocs results.entities, isbnsIndex
    _.log newCandidates, 'newCandidates'
    candidates.add newCandidates
    @showImportQueueUnlessEmpty()
