files_ = require 'lib/files'
importers = require '../../lib/importers'
dataValidator = require '../../lib/data_validator'
ImportQueue = require './import_queue'
Candidates = require '../../collections/candidates'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
screen_ = require 'lib/screen'
papaparse = require('lib/get_assets')('papaparse')
isbn2 = require('lib/get_assets')('isbn2')
commonParser = require '../../lib/parsers/common'
extractIsbnsAndFetchData = require '../../lib/import/extract_isbns_and_fetch_data'

candidates = null

module.exports = Marionette.LayoutView.extend
  id: 'importLayout'
  template: require './templates/import'
  behaviors:
    AlertBox: {}
    Loading: {}
    PreventDefault: {}
    SuccessCheck: {}
    ElasticTextarea: {}

  regions:
    queue: '#queue'

  ui:
    isbnsImporter: '#isbnsImporter'
    isbnsImporterTextarea: '#isbnsImporter textarea'
    isbnsImporterWrapper: '#isbnsImporterWrapper'
    importersWrapper: '#importersWrapper'

  events:
    'change input[type=file]': 'getFile'
    'click input': 'hideAlertBox'
    'click #findIsbns': 'findIsbns'
    'click #emptyIsbns': 'emptyIsbns'

  childEvents:
    'import:done': 'onImportDone'

  initialize: ->
    { @isbnsBatch } = @options

    isbn2.prepare()
    # No need to fetch papaparse if we know we will go straight
    # to the ISBN importer
    if @isbnsBatch? then @hideImporters = true
    else papaparse.prepare()

    candidates or= new Candidates

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
    hideImporters: @hideImporters

  showImportQueueUnlessEmpty: ->
    if candidates.length > 0
      if not @queue.hasView()
        @queue.show new ImportQueue { candidates }

      # Run once @ui.importersWrapper is done sliding up
      @setTimeout screen_.scrollTop.bind(null, @queue.$el), 500

  getFile: (e)->
    source = e.currentTarget.id
    { name, parse, encoding } = importers[source]

    selector = "##{name}-li .loading"

    behaviorsPlugin.startLoading.call @,
      selector: selector
      timeout: 'none'
      progressionEventName: if name is 'ISBNs' then 'progression:ISBNs'

    Promise.all [
      files_.parseFileEventAsText e, true, encoding
      papaparse.get()
      isbn2.get()
    ]
    # We only need the result from the file
    .spread _.Log('uploaded file')
    .tap dataValidator.bind(null, source)
    .then parse
    .map commonParser
    .catch _.ErrorRethrow('parsing error')
    # add the selector to the rejected error
    # so that it can be catched by catchAlert
    .catch error_.Complete('#importersWrapper .warning')
    .then _.Log('parsed')
    .then candidates.addNewCandidates.bind(candidates)
    .tap => behaviorsPlugin.stopLoading.call @, selector
    .then @showImportQueueUnlessEmpty.bind(@)
    .catch forms_.catchAlert.bind(null, @)

  # passing the event to the AlertBox behavior
  hideAlertBox: -> @$el.trigger 'hideAlertBox'

  onImportDone: ->
    @$el.trigger 'check'

  findIsbns: ->
    text = @ui.isbnsImporterTextarea.val()
    unless _.isNonEmptyString(text) then return

    selector = '#isbnsImporterWrapper .loading'

    behaviorsPlugin.startLoading.call @,
      selector: selector
      timeout: 'none'
      progressionEventName: 'progression:ISBNs'

    extractIsbnsAndFetchData text
    .then candidates.addNewCandidates.bind(candidates)
    .then (addedCandidates)=>
      behaviorsPlugin.stopLoading.call @, selector
      if addedCandidates.length > 0 then @showImportQueueUnlessEmpty()
      else throw error_.new 'no ISBN found', 400
    .catch error_.Complete('#isbnsImporterWrapper .warning')
    .catch forms_.catchAlert.bind(null, @)

  emptyIsbns: ->
    @ui.isbnsImporterTextarea.val ''
    @$el.trigger 'elastic:textarea:update'
