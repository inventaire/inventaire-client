ResultsList = require './results_list'
Entities = require 'modules/entities/collections/entities'
WikidataEntities = require 'modules/entities/collections/wikidata_entities'
IsbnEntities = require 'modules/entities/collections/isbn_entities'
FindByIsbn = require './find_by_isbn'
ItemsList = require 'modules/inventory/views/items_list'
EntityEdit = require 'modules/entities/views/editor/entity_edit'
wd_ = require 'lib/wikidata'
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
    @model = app.searches.addNonExisting { query: @query }

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
    unless @sameAsPreviousQuery()
      resultsCache = {}
      _.preq.get app.API.entities.search(search)
      .catch _.preq.catch404
      .then (res)=>
        # hiding the loader
        @authors.empty()
        if res?
          # _.log res, 'query:searchEntities res'
          spreadResults res
        else return
      .then @displayResults.bind(@)
      .catch (err)=>
        # couldn't make the alert Behavior work properly
        # so the triggerMethod '404' thing is a provisory solution
        @alert 'no item found'
        @displayResults()
        _.error err, 'searchEntities err'

      app.execute 'show:loader', {region: @authors}


  displayResults: ->
    { humans, authors, books, editions } = resultsCache

    @showAuthors authors, humans
    @showBooks books
    @showEditions editions

  showAuthors: (authors, humans)->
    if authors?.length is 0 then authors = humans
    if authors?.length > 0
      authorsList = new ResultsList {collection: authors, type: 'authors'}
      @authors.show authorsList

      @saveSearchPictures authors

  showBooks: (books)->
    if books?.length > 0
      booksList = new ResultsList {collection: books, type: 'books' }
      @books.show booksList

      @saveSearchPictures books

  showEditions: (editions)->
    if editions?.length > 0
      editionsList = new ResultsList {collection: editions, type: 'editions' }
      @editions.show editionsList

      @saveSearchPictures editions

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
  _.log res, 'res at spreadResults'
  resultsCache =
    humans: new Entities
    authors: new Entities
    books: new Entities
    editions: new Entities
    search: res.search

  { wd, ol, google } = res

  if wd? then addWikidataEntities wd.items
  if ol? then addIsbnEntities ol.items
  if google? then addIsbnEntities google.items

addWikidataEntities = (resultsArray)->
  # instantiating generic wikidata entities first
  # and only upgrading later on more specific Models
  # as methods on WikidataEntities greatly ease the sorting process
  wdEntities = new WikidataEntities resultsArray
  for model in wdEntities.models
    claims = model.get 'claims'
    if _.isntEmpty(claims['wdt:P31'])
      if wd_.isBook(claims['wdt:P31'])
        resultsCache.books.add model

      if wd_.isHuman(claims['wdt:P31'])
        resultsCache.humans.add model

    if _.isntEmpty(claims['wdt:P106'])
      if wd_.isAuthor(claims['wdt:P106'])
        resultsCache.authors.add model

addIsbnEntities = (resultsArray)->
  # initializing models as IsbnEntities
  editions = new IsbnEntities resultsArray
  # adding them to the less specific editions collection
  resultsCache.editions.add editions.models
