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
    isbnsImporter: '#isbnsImporter'
    isbnsImporterTextarea: '#isbnsImporter textarea'
    isbnsImporterWrapper: '#isbnsImporterWrapper'
    separator: '.separator'
    importersWrapper: '#importersWrapper'

  events:
    'change input[type=file]': 'getFile'
    'click input': 'hideAlertBox'
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

    # Accept ISBNs from the URL to ease development
    isbns = app.request('querystring:get', 'isbns')?.split('|')
    @isbnsBatch or= isbns

    if @isbnsBatch?
      @ui.isbnsImporterTextarea.val @isbnsBatch.join('\n')
      @$el.find('#findIsbns').trigger 'click'

  serializeData: ->
    importers: importers
    inventory: app.user.get('pathname')

  showImportQueueUnlessEmpty: ->
    if @candidates.length > 0
      if not @queue.hasView()
        @queue.show new ImportQueue { @candidates }

      # Run once @ui.importersWrapper is done sliding up
      setTimeout _.scrollTop.bind(null, @queue.$el), 500

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
    @$el.trigger 'check'

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

    alreadyAddedIsbns = candidates.pluck 'normalizedIsbn'

    reorderCandidates = newCandidates
      .concat results.notFound, results.invalidIsbn
      .filter (candidate)-> candidate.normalizedIsbn not in alreadyAddedIsbns
      # Make sure to display candidates in the order they where input
      # to help the user fill the missing information
      .sort byIndex(isbnsIndex)

    candidates.add reorderCandidates, { merge: true }
    @showImportQueueUnlessEmpty()

byIndex = (isbnsIndex)-> (a, b)->
  isbnsIndex[a.normalizedIsbn].index - isbnsIndex[b.normalizedIsbn].index
