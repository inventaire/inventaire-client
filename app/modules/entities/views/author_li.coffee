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

  initialize: ->
    @initPlugins()
    @collection = new Backbone.Collection
    # trigger fetchbooks once the author is in view
    @$el.once 'inview', @fetchBooks.bind(@)
    @listenTo @model, 'change', @lazyRender.bind(@)

  initPlugins: ->
    _.extend @, behaviorsPlugin
    paginationPlugin.call @, 15, (@options.initialLength or 5)
    wikiBarPlugin.call @

  events:
    'click a.displayMore': 'displayMore'

  modelEvents:
    'add:pictures': 'lazyRender'

  collectionEvents:
    # required to get access to the collection real length from pagination::more
    'add': 'lazyRender'

  serializeData: ->
    _.extend @model.toJSON(),
      wikipediaPreview: @options.wikipediaPreview or true
      more: @more()

  fetchBooks: ->
    @startLoading()

    wdAuthors_.fetchAuthorsBooks(@model)
    .then @addToCollection.bind(@)
    .catch _.Error('author_li fetchBooks err')
    .finally @stopLoading.bind(@)

  addToCollection: (models)->
    if models? then models.forEach @collection.add.bind(@collection)
    else 'no book found for #{@model.title}'

  onShow: ->
    if @options.standalone then @model.updateTwitterCard()
