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
    worksRegion: '#works'

  ui:
    headerBg: '.headerBg'

  behaviors:
    Loading: {}

  initialize: ->
    @initPlugins()
    @initCollections()

    # TODO: pass the 'refresh' option downstream
    @fetchWorksAndAuthors()
    .then @setHeaderBackground.bind(@)

  initPlugins: ->
    _.extend @, behaviorsPlugin

  initCollections: ->
    @works = new Entities
    @authors = new Entities

  fetchWorksAndAuthors: ->
    genre_.fetchWorksAndAuthors @model
    .then genre_.spreadWorksAndAuthors.bind(null, @works, @authors)
    .catch _.Error('fetchWorksAndAuthors')
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
    if @works?
      for work in @works.models
        image = work.get 'image.url'
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
    for type in ['authors', 'works']
      collection = @[type]
      region = @["#{type}Region"]
      region.show new ResultsList
        collection: collection
        type: type
        hideIfEmpty: true
