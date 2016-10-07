wd_ = require 'lib/wikimedia/wikidata'
commons_ = require 'lib/wikimedia/commons'
wdGenre_ = require 'modules/entities/lib/wikidata/genre'
Entities = require 'modules/entities/collections/entities'
ResultsList = require 'modules/search/views/results_list'
wikiBarPlugin = require 'modules/general/plugins/wiki_bar'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
GenreData = require './genre_data'

module.exports = Marionette.LayoutView.extend
  id: 'genreLayout'
  template: require './templates/genre_layout'
  regions:
    genreRegion: '#genre'
    authorsRegion: '#authors'
    booksRegion: '#books'

  ui:
    headerBg: '.headerBg'

  behaviors:
    Loading: {}

  initialize: ->
    @initPlugins()
    @initCollections()
    @fetchBooksAndAuthors()
    @fetchAndSetHeaderBackground()

  initPlugins: ->
    wikiBarPlugin.call @
    _.extend @, behaviorsPlugin

  initCollections: ->
    @books = new Entities
    @authors = new Entities

  fetchBooksAndAuthors: ->
    wdGenre_.fetchBooksAndAuthors @model
    .then wdGenre_.spreadBooksAndAuthors.bind(null, @books, @authors)
    .catch _.Error('fetchBooksAndAuthors')
    .then @stopLoading.bind(@)
    # retrying to fetchAndSetHeaderBackground with books data
    # in case the model has no image
    .then @fetchAndSetHeaderBackground.bind(@)
    .then @blockLoader.bind(@)

  blockLoader: ->
    @_dataFetched = true

  fetchAndSetHeaderBackground: ->
    unless @_headerBackgroundSet
      wmCommonsFile = @findPicture()
      if wmCommonsFile?
        @_headerBackgroundSet = true
        commons_.thumb wmCommonsFile, window.screen.width
        .then @setHeaderBackground.bind(@)
        .catch _.Error('fetchAndSetHeaderBackground')

  findPicture: ->
    @findModelFirstPicture() or @findEntitiesFirstPicture()

  findModelFirstPicture: ->
    @model.get('claims.wdt:P18')?[0]

  findEntitiesFirstPicture: ->
    if @books?
      images = @books.map (entity)->
        pics = entity.get('claims.wdt:P18')
        return pics?[0]

      return _.compact(images)[0]

  setHeaderBackground: (url)->
    @headerBgUrl = url
    # showHeaderBackground is called at render but need to be called
    # if the view was already rendered when the data arrives
    if @isRendered then @showHeaderBackground()

  onRender: ->
    unless @_dataFetched then @startLoading()
    @showHeaderBackground()
    @showGenreData()
    @showResults()

  showHeaderBackground: ->
    if @headerBgUrl?
      @ui.headerBg.css 'background-image', "url(#{@headerBgUrl})"
      @$el.addClass 'with-bg-image'

  showGenreData: ->
    @genreRegion.show new GenreData { @model }

  showResults: ->
    for type in ['authors', 'books']
      collection = @[type]
      region = @["#{type}Region"]
      region.show new ResultsList
        collection: collection
        type: type
        hideIfEmpty: true
