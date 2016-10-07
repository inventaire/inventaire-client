ResultsList = require './results_list'
Entities = require 'modules/entities/collections/entities'
{ WikidataEntities, InvEntities } = require 'modules/entities/collections/structured_entities'
IsbnEntities = require 'modules/entities/collections/isbn_entities'
FindByIsbn = require './find_by_isbn'
ItemsList = require 'modules/inventory/views/items_list'
EntityEdit = require 'modules/entities/views/editor/entity_edit'
wd_ = require 'lib/wikimedia/wikidata'
books_ = require 'lib/books'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
searchInputData = require 'modules/general/views/menu/search_input_data'

resultsCache = {}

module.exports = Marionette.LayoutView.extend
  id: 'searchLayout'
  template: require './templates/search'
  behaviors:
    AlertBox: {}
    LocalSeachBar: {}

  regions:
    inventoryItems: '#inventoryItems'
    authors: '#authors'
    books: '#books'
    editions: '#editions'

  ui:
    showFindByIsbnButton: '#showFindByIsbn'
    findByIsbnForm: '#findByIsbnForm'
    localSearchField: '#localSearchField'

  initialize: (params)->
    _.extend @, behaviorsPlugin
    @query = params.query
    @queryIsIsbn = books_.isIsbn @query
    @model = app.searches.addNonExisting { @query }

  serializeData: ->
    queryIsIsbn: @queryIsIsbn
    search: searchInputData 'localSearch', true
    findByIsbn:
      nameBase: 'findIsbn'
      field:
        name: 'isbn'
        placeholder: _.i18n 'ex: 978-2-07-036822-8'
        dotdotdot: ''
      button:
        icon: 'search'
        classes: 'secondary postfix'

  events:
    'click #showFindByIsbn a': 'showFindByIsbn'
    'click .scanner': -> app.execute 'show:scan'
    'click #findIsbnButton': 'searchByIsbn'
    'click #createEntity': 'createEntity'

  onShow: ->
    app.request 'wait:for', 'friends:items'
    .then @showItems.bind(@)

    @searchEntities()

  updateSearchBar: ->
    @ui.localSearchField.val @query

  showItems: ->
    collection = app.items.filtered.resetFilters().filterByText @query
    if collection.length > 0
      @inventoryItems.show new ItemsList
        collection: collection
        header:
          text: 'matching books in your network'
          classes: 'subheader'

  sameAsPreviousQuery: ->
    resultsLength = resultsCache.books?.length or resultsCache.editions?.length
    # verifying that the query is not the same as the last one
    # and using the previous results if so
    if resultsCache.search is @query and resultsLength > 0
      @displayResults()
      @authors.$el.hide().fadeIn(200)
      return true

  searchEntities: ->
    search = @query
    _.log search, 'search'
    if @sameAsPreviousQuery() then return

    resultsCache = {}
    _.preq.get app.API.entities.search(search)
    .catch _.preq.catch404
    .then @_parseResponse.bind(@)
    .then @displayResults.bind(@)
    .catch @_catchErr.bind(@)

    app.execute 'show:loader', {region: @authors}

  _parseResponse: (res)->
    # hiding the loader
    @authors.empty()
    if res? then spreadResults res

  _catchErr: (err)->
    @alert 'no item found'
    @displayResults()
    _.error err, 'searchEntities err'

  displayResults: ->
    { humans, authors, books, editions } = resultsCache
    if authors?.length is 0 then authors = humans

    dedupplicateAuthorsBooks authors, books

    @_displayTypeResults authors, 'authors'
    @_displayTypeResults books, 'books'
    @_displayTypeResults editions, 'editions'

  _displayTypeResults: (collection, type)->
    if collection?.length > 0
      list = new ResultsList { collection, type }
      @[type].show list

      @saveSearchPictures collection

  showFindByIsbn: ->
    @ui.showFindByIsbnButton.slideUp()
    @ui.findByIsbnForm.slideDown()

  saveSearchPictures: (collection)->
    # keep only every entity first picture to avoid passing
    # several possibily identical pictures for a single entity
    pictures = collection.map firstPicture
    @model.savePictures pictures

  searchByIsbn: ->
    query = $('input#findIsbnField').val()
    _.log query, 'isbn query'
    app.execute 'search:global', query

  createEntity: -> app.execute 'show:entity:create', 'book', @query

firstPicture = (model)-> model.get('pictures')[0]

spreadResults = (res)->
  resultsCache =
    humans: new Entities
    authors: new Entities
    books: new Entities
    editions: new Entities
    search: res.search

  { wd, inv, dataseed } = res

  if wd? then addWikidataEntities wd.results
  if inv? then addInvEntities inv.results
  if dataseed? then addIsbnEntities dataseed.results

addStructuredEntities = (Collection, resultsArray)->
  # instantiating generic wikidata entities first
  # and only upgrading later on more specific Models
  # as methods on Collection greatly ease the sorting process
  entities = new Collection resultsArray
  for entity in entities.models
    switch wd_.type entity
      when 'book' then resultsCache.books.add entity
      when 'human'
        # Add it to humans in any case
        resultsCache.humans.add entity
        # But if we happen to find entities with the occupation author,
        # we will keep those only to avoid getting all sorts of non-authors
        # humans poping up in results (see @displayResults above)
        { 'wdt:P106':P106 } = entity.claims
        if wd_.isAuthor P106 then resultsCache.authors.add entity

addWikidataEntities = addStructuredEntities.bind null, WikidataEntities
addInvEntities = addStructuredEntities.bind null, InvEntities

addIsbnEntities = (resultsArray)->
  # initializing models as IsbnEntities
  editions = new IsbnEntities resultsArray
  # adding them to the less specific editions collection
  resultsCache.editions.add editions.models

dedupplicateAuthorsBooks = (authors, books)->
  authorsUris = authors.models.map (author)-> author.get 'uri'

  # Remove books that have an author in the authors list
  # as they will appear in the author's books list instead
  toRemove = []
  books.forEach (book)->
    if _.haveAMatch book.claims['wdt:P50'], authorsUris
      # Not removing directly as it would alter the forEach loop
      toRemove.push book

  books.remove toRemove
