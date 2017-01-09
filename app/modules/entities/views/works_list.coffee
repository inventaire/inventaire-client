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
      when 'work' then require './work_li'
      when 'article' then require './article_li'
      else throw error_.new "unknown work type: #{type}", model

  childViewOptions: (model, index)->
    refresh: @options.refresh

  ui:
    counter: '.counter'
    more: 'div.more'
    moreCounter: 'div.more .counter'

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
      if @more() then @ui.moreCounter.text @more()
      else @ui.more.hide()

  startMoreLoading: -> @ui.moreCounter.html spinner

  serializeData: ->
    title: @options.type
    hideHeader: @options.hideHeader
    more: @more()
    canRefreshData: true
    totalLength: @collection.totalLength
