wdAuthors_ = require 'modules/entities/lib/wikidata/authors'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
paginationPlugin = require 'modules/general/plugins/pagination'
wikiBarPlugin = require 'modules/general/plugins/wiki_bar'

module.exports = Marionette.CompositeView.extend
  template: require './templates/author_li'
  tagName: 'li'
  className: 'authorLi'
  behaviors:
    Loading: {}

  childViewContainer: '.authorsBooks'
  childView: require './book_li'
  emptyView: require 'modules/inventory/views/no_item'

  ui:
    bookCounter: '.books .counter'

  initialize: ->
    @initPlugins()
    @collection = new Backbone.Collection
    @initBookCounter()
    # trigger fetchbooks once the author is in view
    @$el.once 'inview', @fetchBooks.bind(@)
    @listenTo @model, 'change', @lazyRender.bind(@)
    if @options.standalone
      app.execute 'metadata:update:needed'


  initPlugins: ->
    _.extend @, behaviorsPlugin
    paginationPlugin.call @, 15, (@options.initialLength or 5)
    if @options.standalone
      wikiBarPlugin.call @

  initBookCounter: ->
    @lazyUpdateBookCounter = _.debounce @updateBookCounter.bind(@), 1000
    @listenTo @collection, 'add remove', @lazyUpdateBookCounter

  events:
    'click a.displayMore': 'displayMore'
    'click .refreshData': 'refreshData'

  modelEvents:
    'add:pictures': 'lazyRender'

  collectionEvents:
    # required to get access to the collection real length from pagination::more
    'add': 'lazyRender'

  serializeData: ->
    _.extend @model.toJSON(),
      more: @more()
      standalone: @options.standalone
      canRefreshData: true

  fetchBooks: ->
    # make sure refresh is a Boolean and not an object incidently passed
    refresh = @options.refresh is true

    @startLoading()

    wdAuthors_.fetchAuthorsBooks @model, refresh
    .then @addToCollection.bind(@)
    .catch _.Error('author_li fetchBooks err')
    .finally @stopLoading.bind(@)

  addToCollection: (models)->
    unless models? then return _.warn 'no book found for #{@model.title}'
    @collection.add models

  onShow: ->
    if @options.standalone
      @model.updateMetadata()
      .finally app.execute.bind(app, 'metadata:update:done')

  onRender: ->
    @lazyUpdateBookCounter()

  refreshData: -> app.execute 'show:entity:refresh', @model

  updateBookCounter: ->
    count = @collection.length
    @ui.bookCounter.text(count).hide().slideDown()
