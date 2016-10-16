spinner = _.icon 'circle-o-notch', 'fa-spin'

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
    displayMore: '.displayMore'
    more: '.displayMore .counter'

  initialize: ->
    @collection = @options.collection

    initialLength = @options.initialLength or 5
    @batchLength = @options.batchLength or 15

    @fetchMore = @collection.fetchMore.bind @collection
    @more = @collection.more.bind @collection

    # First fetch
    @collection.firstFetch initialLength

  events:
    'click a.displayMore': 'displayMore'

  displayMore: ->
    @startMoreLoading()

    @collection.fetchMore @batchLength
    .then =>
      if @more() then @ui.more.text @more()
      else @ui.displayMore.hide()

  startMoreLoading: -> @ui.more.html spinner

  serializeData: ->
    title: @options.type
    more: @more()
    canRefreshData: true
    totalLength: @collection.totalLength
