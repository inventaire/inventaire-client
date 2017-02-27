behaviorsPlugin = require 'modules/general/plugins/behaviors'
masonryPlugin = require 'modules/general/plugins/masonry'
itemsPerPage = require 'modules/inventory/lib/items_per_pages'

module.exports = Marionette.CompositeView.extend
  className: 'itemsListWrapper'
  template: require './templates/items_list'
  childViewContainer: '.itemsList'
  childView: require './item_figure'
  emptyView: require './no_item'
  behaviors:
    Loading: {}

  ui:
    itemsList: '.itemsList'

  childViewOptions: ->
    showDistance: @options.showDistance

  initialize: ->
    { @more, @fetchMore } = @options

    masonryPlugin.call @, '.itemsList', '.itemContainer'

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
    if @options.more()
      @startLoading()
      @fetchMore().then @stopLoading.bind(@)

  startLoading: -> behaviorsPlugin.startLoading.call @, '.fetchMore'
  stopLoading: -> behaviorsPlugin.stopLoading.call @, '.fetchMore'
