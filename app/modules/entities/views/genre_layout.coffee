wd_ = require 'lib/wikidata'
wdGenre_ = require 'modules/entities/lib/wikidata/genre'
Entities = require 'modules/entities/collections/entities'
ResultsList = require 'modules/search/views/results_list'
wikiBarPlugin = require 'modules/general/plugins/wiki_bar'

module.exports = Marionette.LayoutView.extend
  id: 'genreLayout'
  template: require './templates/genre_layout'
  regions:
    authorsRegion: '#authors'
    booksRegion: '#books'

  ui:
    headerBg: '.headerBg'

  behaviors:
    Loading: {}

  initialize: ->
    _.inspect @, 'genre'
    @initPlugins()
    @initCollections()
    @fetchBooksAndAuthors()
    @fetchAndSetHeaderBackground()

  initPlugins: ->
    wikiBarPlugin.call @

  initCollections: ->
    @books = new Entities
    @authors = new Entities

  fetchBooksAndAuthors: ->
    wdGenre_.fetchBooksAndAuthors @model
    .then wdGenre_.spreadBooksAndAuthors.bind(null, @books, @authors)
    # .then @showResults.bind(@)
    .catch _.Error('fetchBooksAndAuthors')

  fetchAndSetHeaderBackground: ->
    wmCommonsFile = @model.get('claims.P18')?[0]
    if wmCommonsFile?
      wd_.wmCommonsThumb(wmCommonsFile, window.screen.width)
      .then @setHeaderBackground.bind(@)
      .catch _.Error('fetchAndSetHeaderBackground')

  setHeaderBackground: (url)->
    @headerBgUrl = url
    # showHeaderBackground is called at render but need to be called
    # if the view was already rendered when the data arrives
    if @isRendered then @showHeaderBackground()

  onRender: ->
    @showHeaderBackground()

  onShow: ->
    @showResults()

  showHeaderBackground: ->
    if @headerBgUrl?
      @ui.headerBg.css 'background-image', "url(#{@headerBgUrl})"
      @$el.addClass 'with-bg-image'


  showResults: ->
    ['authors', 'books'].forEach (type)=>
      collection = @[type]
      region = @["#{type}Region"]
      region.show new ResultsList
        collection: collection
        type: type
        hideIfEmpty: true
