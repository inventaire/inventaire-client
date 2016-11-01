ResultsList = require './results_list'
Entities = require 'modules/entities/collections/entities'
FindByIsbn = require './find_by_isbn'
ItemsList = require 'modules/inventory/views/items_list'
EntityEdit = require 'modules/entities/views/editor/entity_edit'
wd_ = require 'lib/wikimedia/wikidata'
isbn_ = require 'lib/isbn'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
searchInputData = require 'modules/general/views/menu/search_input_data'

# An object to cache search results from one search to the next
cache = {}

module.exports = Marionette.LayoutView.extend
  id: 'searchLayout'
  template: require './templates/search'
  behaviors:
    AlertBox: {}
    LocalSeachBar: {}

  regions:
    inventoryItems: '#inventoryItems'
    authors: '#authors'
    series: '#series'
    books: '#books'
    editions: '#editions'

  ui:
    showFindByIsbnButton: '#showFindByIsbn'
    findByIsbnForm: '#findByIsbnForm'
    localSearchField: '#localSearchField'

  initialize: (params)->
    _.extend @, behaviorsPlugin
    @query = params.query
    @queryIsIsbn = isbn_.isIsbn @query
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
    # Verifying that the query is not the same as the last one
    # and using the previous results if so
    if cache.search is @query and cache.length > 0
      @displayResults()
      @authors.$el.hide().fadeIn 200
      return true

  searchEntities: ->
    search = @query
    if @sameAsPreviousQuery() then return

    # Reset cache
    cache = { search }

    _.preq.get app.API.entities.search(search, @options.refresh)
    .catch _.preq.catch404
    .then @_parseResponse.bind(@)
    .then @displayResults.bind(@)
    .catch @_catchErr.bind(@)

    app.execute 'show:loader', { region: @authors }

  _parseResponse: (res)->
    # hiding the loader
    @authors.empty()
    if res? then spreadResults res

  _catchErr: (err)->
    if err.status is 404 then @alert 'no item found'
    else _.error err, 'searchEntities err'
    @displayResults()

  displayResults: ->
    { humans, series, books, editions } = cache

    _.log cache, 'cache'

    authorsUris = humans.models.map getUri
    seriesUris = series.models.map getUri
    dedupplicateSubEntities authorsUris, series, 'wdt:P50'
    dedupplicateSubEntities authorsUris, books, 'wdt:P50'
    dedupplicateSubEntities seriesUris, books, 'wdt:P179'

    # Eventually, add a filter to display humans with occupation writter only
    @_displayTypeResults humans, 'authors'
    @_displayTypeResults series, 'series'
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
    pictures = collection.map (model)-> model.get('image.url')
    @model.savePictures pictures

  searchByIsbn: ->
    query = $('input#findIsbnField').val()
    _.log query, 'isbn query'
    app.execute 'search:global', query

  createEntity: -> app.execute 'show:entity:create', 'book', @query

spreadResults = (res)->
  { humans, series, books, editions } = res
  cache.humans = new Entities humans
  cache.series = new Entities series
  cache.books = new Entities books
  cache.editions = new Entities editions
  cache.length = humans.length + series.length + books.length + editions.length
  return

# Remove books and series that have an author in the authors list or books that are
# part of a found serie as they will fetched and displayed in the author's or serie's
# subentities list
dedupplicateSubEntities = (authorsUris, subentities, subentitiesProperty)->
  toRemove = []
  subentities.forEach (subentity)->
    if _.haveAMatch subentity.get("claims.#{subentitiesProperty}"), authorsUris
      # Not removing directly as it would conflict with the forEach loop
      toRemove.push subentity

  subentities.remove toRemove

getUri = (model)-> model.get 'uri'
