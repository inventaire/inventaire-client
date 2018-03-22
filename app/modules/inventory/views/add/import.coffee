files_ = require 'lib/files'
importers = require '../../lib/importers'
dataValidator = require '../../lib/data_validator'
ImportQueue = require './import_queue'
Candidates = require '../../collections/candidates'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
papaparse = require('lib/get_assets')('papaparse')
isbn2 = require('lib/get_assets')('isbn2')

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

  events:
    'change input[type=file]': 'getFile'
    'click input': 'hideAlertBox'
    'click #addedItems': 'showMainUserInventory'
    'click #findIsbns': 'findIsbns'

  childEvents:
    'import:done': 'onImportDone'

  initialize: ->
    { @isbnsBatch } = @options

    isbn2.prepare()
    # No need to fetch papaparse if we know we will go straight
    # to the ISBN importer
    unless @isbnsBatch? then papaparse.prepare()

    @candidates = candidates or= new Candidates

  onShow: ->
    # show the import queue if there were still candidates from last time
    @showImportQueueUnlessEmpty()
    @listenTo @candidates, 'reset', @hideImportQueueIfEmpty.bind(@)

    if @isbnsBatch?
      @ui.isbnsImporterTextarea.val @isbnsBatch.join('\n')
      @$el.find('#findIsbns').trigger 'click'

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

      # Run once @ui.importersWrapper is done sliding up
      setTimeout _.scrollTop.bind(null, @queue.$el), 500

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

  findIsbns: ->
    text = @ui.isbnsImporterTextarea.val()
    unless _.isNonEmptyString(text) then return

    isbn2.get()
    .then =>
      # window.ISBN should now be initalized
      isbnsData = extractIsbns text

      if isbnsData.length is 0 then return

      @ui.separator.hide()
      @ui.importersWrapper.slideUp 400
      @ui.importersWrapper.find('.warning').show()

      fetchEntitiesSequentially isbnsData
      .then @displayResults.bind(@)

  displayResults: (data)->
    { results, isbnsIndex } = data
    newCandidates = getCandidatesFromEntitiesDocs results.entities, isbnsIndex
    notFoundCandidates = results.notFound.map serializeIsbnData
    invalidCandidates = results.invalidIsbn.map serializeIsbnData
    # Make sure to display candidates in the order they where input
    # to help the user fill the missing information
    reorderCandidates = newCandidates
      .concat notFoundCandidates, invalidCandidates
      .sort byIndex(isbnsIndex)

    candidates.add reorderCandidates, { merge: true }
    @showImportQueueUnlessEmpty()

serializeIsbnData = (isbnData)->
  isbn: isbnData.normalized
  rawIsbn: isbnData.raw
  isValid: isbnData.isValid

byIndex = (isbnsIndex)-> (a, b)->
  isbnsIndex[a.isbn].index - isbnsIndex[b.isbn].index
