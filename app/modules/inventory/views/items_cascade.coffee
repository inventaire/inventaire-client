behaviorsPlugin = require 'modules/general/plugins/behaviors'
masonryPlugin = require 'modules/general/plugins/masonry'
alwaysFalse = -> false

module.exports = Marionette.CompositeView.extend
  className: 'itemsCascadeWrapper'
  template: require './templates/items_cascade'
  childViewContainer: '.itemsCascade'
  childView: require './item_card'
  emptyView: require './no_item'
  behaviors:
    Loading: {}

  ui:
    itemsCascade: '.itemsCascade'

  childViewOptions: ->
    showDistance: @options.showDistance

  initialize: ->
    { @hasMore, @fetchMore } = @options
    @hasMore or= alwaysFalse
    @_fetching = false

    masonryPlugin.call @, '.itemsCascade', '.itemContainer'

  serializeData: ->
    header: @options.header

  events:
    'inview .fetchMore': 'infiniteScroll'

  collectionEvents:
    'filtered:add': 'lazyMasonryRefresh'

  childEvents:
    'render': 'lazyMasonryRefresh'
    'resize': 'lazyMasonryRefresh'

  infiniteScroll: ->
    if @_fetching or not @hasMore() then return
    @_fetching = true
    @startLoading()

    @fetchMore()
    .then @stopLoading.bind(@)
    # Give the time for the DOM to update
    .delay 200
    .finally => @_fetching = false

  startLoading: -> behaviorsPlugin.startLoading.call @, '.fetchMore'
  stopLoading: -> behaviorsPlugin.stopLoading.call @, '.fetchMore'
