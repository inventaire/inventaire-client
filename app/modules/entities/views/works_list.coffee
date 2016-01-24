paginationPlugin = require 'modules/general/plugins/pagination'

module.exports = Marionette.CompositeView.extend
  template: require './templates/works_list'
  behaviors:
    Loading: {}

  childViewContainer: '.container'
  getChildView: ->
    if @options.type is 'articles' then require './article_li'
    else require './book_li'

  emptyView: require 'modules/inventory/views/no_item'

  ui:
    counter: '.counter'

  initialize: ->
    @initPlugins()
    @collection = @options.collection
    @initBookCounter()

  initPlugins: ->
    paginationPlugin.call @,
      batchLength: 15
      initialLength: @options.initialLength or 5

  initBookCounter: ->
    @lazyUpdateBookCounter = _.debounce @updateBookCounter.bind(@), 1000
    @listenTo @collection, 'add remove', @lazyUpdateBookCounter

  events:
    'click a.displayMore': 'displayMore'

  collectionEvents:
    # required to get access to the collection real length from pagination::more
    'add': 'lazyRender'

  serializeData: ->
    _.extend {}, strings[@options.type],
      more: @more()
      canRefreshData: true

  onRender: ->
    @lazyUpdateBookCounter()

  updateBookCounter: ->
    count = @collection.length
    # test text function existance to prevent crashes when the DOM isn't ready
    @ui.counter.text?(count).hide().slideDown()

strings =
  books:
    title: 'books'
  articles:
    title: 'articles'
