wdAuthors_ = require 'modules/entities/lib/wikidata/authors'
loadingPlugin = require 'modules/general/plugins/loading'
paginationPlugin = require 'modules/general/plugins/pagination'

module.exports = AuthorLi = Backbone.Marionette.CompositeView.extend
  template: require './templates/author_li'
  tagName: "li"
  className: "authorLi"
  behaviors:
    Loading: {}
    WikiBar: {}

  childViewContainer: '.authorsBooks'
  childView: require './book_li'
  emptyView: require 'modules/inventory/views/no_item'

  initialize: ->
    @initPlugins()
    @collection = new Backbone.Collection
    @$el.once 'inview', @fetchBooks.bind(@)

  initPlugins: ->
    _.extend @, loadingPlugin
    paginationPlugin.call(@, 5)

  events:
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'
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
    .always @stopLoading.bind(@)

  addToCollection: (models)->
    if models? then models.forEach @collection.add.bind(@collection)
    else 'no book found for #{@model.title}'

  toggleWikipediaPreview: -> @$el.trigger 'toggleWikiIframe', @
