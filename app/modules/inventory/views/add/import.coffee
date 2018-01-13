files_ = require 'lib/files'
importers = require '../../lib/importers'
dataValidator = require '../../lib/data_validator'
ImportQueue = require './import_queue'
Candidates = require '../../collections/candidates'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
isbn_ = require 'lib/isbn'
papaparse = require('lib/get_assets')('papaparse')
getBestLangValue = sharedLib('get_best_lang_value')(_)
wd_ = require 'lib/wikimedia/wikidata'

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

isbnPattern = /(97(8|9))?[\d\-]{9,13}([\dX])/g

extractIsbns = (text)->
  text.match isbnPattern
  .map (rawIsbn)-> { raw: rawIsbn, normalized: isbn_.normalizeIsbn(rawIsbn) }
  .filter (obj)-> isbn_.isNormalizedIsbn(obj.normalized)
  .filter firstOccurence({})

firstOccurence = (isbnRoots)-> (isbnData)->
  { normalized:isbn } = isbnData
  # Find the part that would be in common between ISBN 10 and 13
  isbnRoot = if isbn.length is 13 then isbn[3..11] else isbn[0..8]
  # and use it to keep only one version of a given root
  if isbnRoots[isbnRoot]?
    return false
  else
    isbnRoots[isbnRoot] = true
    return true

# Fetching sequentially to lower stress on the different APIs
fetchEntitiesSequentially = (isbnsData)->
  isbnsIndex = {}
  isbnsData.forEach (isbnData)->
    isbnData.rawUri = "isbn:#{isbnData.normalized}"
    isbnsIndex[isbnData.normalized] = isbnData

  uris = _.pluck isbnsData, 'rawUri'

  commonRes =
    entities: {}
    redirects: {}
    notFound: []

  fetchBatchesRecursively = ->
    batch = uris.splice 0, 9
    if batch.length is 0 then return

    _.preq.get app.API.entities.getByUris(batch, false, relatives)
    .then (res)->
      _.extend commonRes.entities, res.entities
      _.extend commonRes.redirects, res.redirects
      res.notFound?.forEach (notFoundData)->
        isbnData = isbnsIndex[notFoundData.isbn]
        commonRes.notFound.push isbnData
    .then fetchBatchesRecursively

  fetchBatchesRecursively()
  .then -> { results: commonRes, isbnsIndex }

# Fetch the works associated to the editions, and those works authors
# to get access to the authors labels
relatives = [ 'wdt:P629', 'wdt:P50', ]

getCandidatesFromEntitiesDocs = (entities, isbnsIndex)->
  newCandidates = []
  for uri, entity of entities
    if entity.type is 'edition'
      { claims } = entity
      # Match the attributes expected by
      # modules/inventory/views/add/templates/candidate_row.hbs
      entity.title = claims['wdt:P1476'][0]
      entity.authors = getEditionAuthors entity, entities
      _.log entity.authors, 'entity.authors'
      normalizedIsbn13 = isbn_.normalizeIsbn claims['wdt:P212'][0]
      normalizedIsbn10 = isbn_.normalizeIsbn claims['wdt:P957'][0]
      isbnData = isbnsIndex[normalizedIsbn13] or isbnsIndex[normalizedIsbn10]
      # Use the input ISBN to allow the user to find it back in her list
      entity.isbn = isbnData.raw
      newCandidates.push entity

  return newCandidates

getEditionAuthors = (edition, entities)->
  editionLang = wd_.getOriginalLang edition.claims

  worksUris = edition.claims['wdt:P629']
  works = _.values _.pick(entities, worksUris)

  authorsUris = _.flatten works.map(getWorkAuthors)
  authors = _.values _.pick(entities, authorsUris)
  return authors
    .map (author)-> getBestLangValue(editionLang, null, author.labels).value
    .join ', '

getWorkAuthors = (work)-> work.claims['wdt:P50']
