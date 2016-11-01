wd_ = require 'lib/wikimedia/wikidata'
commons_ = require 'lib/wikimedia/commons'
genre_ = require 'modules/entities/lib/types/genre'
Entities = require 'modules/entities/collections/entities'
ResultsList = require 'modules/search/views/results_list'
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
    WikiBar: {}

  initialize: ->
    @initPlugins()
    @initCollections()

    @fetchBooksAndAuthors()
    .then @setHeaderBackground.bind(@)

  initPlugins: ->
    _.extend @, behaviorsPlugin

  initCollections: ->
    @books = new Entities
    @authors = new Entities

  fetchBooksAndAuthors: ->
    genre_.fetchBooksAndAuthors @model
    .then genre_.spreadBooksAndAuthors.bind(null, @books, @authors)
    .catch _.Error('fetchBooksAndAuthors')
    .then @stopLoading.bind(@)
    .then @blockLoader.bind(@)

  blockLoader: ->
    @_dataFetched = true

  setHeaderBackground: ->
    image = @findImage()
    if image?
      @headerBgUrl = image
      if @isRendered then @showHeaderBackground()

  findImage: ->
    @findModelFirstImage() or @findEntitiesFirstImage()

  findModelFirstImage: -> @model.get 'image.url'
  findEntitiesFirstImage: ->
    if @books?
      for book in @books.models
        image = book.get 'image.url'
        if image? then return image

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
