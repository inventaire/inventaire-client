wdAuthors_ = require 'modules/entities/lib/wikidata/authors'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
wikiBarPlugin = require 'modules/general/plugins/wiki_bar'
WorksList = require './works_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/author_li'
  tagName: 'li'
  className: 'authorLi'
  behaviors:
    Loading: {}

  regions:
    booksRegion: '.books'
    articlesRegion: '.articles'

  initialize: ->
    @initPlugins()
    @books = new Backbone.Collection
    @articles = new Backbone.Collection
    @lazyRender = _.LazyRender @
    # trigger fetchbooks once the author is in view
    @$el.once 'inview', @fetchBooks.bind(@)
    @listenTo @model, 'change', @lazyRender.bind(@)
    if @options.standalone
      app.execute 'metadata:update:needed'


  initPlugins: ->
    _.extend @, behaviorsPlugin
    if @options.standalone
      wikiBarPlugin.call @

  events:
    'click .refreshData': 'refreshData'

  modelEvents:
    'add:pictures': 'lazyRender'

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @options.standalone
      canRefreshData: true
      # having an epub download button on an author isn't really interesting
      hideWikisourceEpub: true

  fetchBooks: ->
    # make sure refresh is a Boolean and not an object incidently passed
    refresh = @options.refresh is true

    @startLoading()

    wdAuthors_.fetchAuthorsWorks @model, refresh
    .then @addToCollections.bind(@)
    .catch _.Error('author_li fetchBooks err')
    .finally @stopLoading.bind(@)

  addToCollections: (works)->
    { books, articles } = works
    unless books? or articles?
      return _.warn 'no work found for #{@model.title}'
    @books.add books
    @articles.add articles

    # only show articles yet to make this test possible
    if @articles.length > 0 then @showArticles()

  onRender: ->
    @showBooks()
    if @options.standalone
      @model.updateMetadata()
      .finally app.Execute('metadata:update:done')

  showBooks: ->
    @booksRegion.show new WorksList
      collection: @books
      type: 'books'

  showArticles: ->
    @articlesRegion.show new WorksList
      collection: @articles
      type: 'articles'

  refreshData: -> app.execute 'show:entity:refresh', @model
