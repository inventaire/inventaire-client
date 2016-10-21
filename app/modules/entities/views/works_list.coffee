spinner = _.icon 'circle-o-notch', 'fa-spin'
error_ = require 'lib/error'

module.exports = Marionette.CompositeView.extend
  template: require './templates/works_list'
  className: 'worksList'
  behaviors:
    Loading: {}

  childViewContainer: '.container'
  getChildView: (model)->
    { type } = model
    switch type
      when 'serie' then require './serie_layout'
      when 'book' then require './book_li'
      when 'article' then require './article_li'
      else throw error_.new "unknown work type: #{type}", model

  childViewOptions: (model, index)->
    refresh: @options.refresh

  emptyView: require 'modules/inventory/views/no_item'

  ui:
    counter: '.counter'
    displayMore: '.displayMore'
    more: '.displayMore .counter'

  initialize: ->
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
    hideHeader: @options.hideHeader
    more: @more()
    canRefreshData: true
    totalLength: @collection.totalLength
