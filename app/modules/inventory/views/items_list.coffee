behaviorsPlugin = require 'modules/general/plugins/behaviors'
paginationPlugin = require 'modules/general/plugins/pagination'
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
    @initPlugins()

  initPlugins: ->
    _.extend @, behaviorsPlugin
    paginationPlugin.call @,
      batchLength: itemsPerPage()
      fetchMore: @options.fetchMore
      more: @options.more

    masonryPlugin.call @, '.itemsList', '.itemContainer'

  serializeData: ->
    header: @options.header

  events:
    'inview .more': 'infiniteScroll'

  collectionEvents:
    'render': 'stopLoading'
    'filtered:add': 'lazyMasonryRefresh'

  childEvents:
    'render': 'lazyMasonryRefresh'
    'resize': 'lazyMasonryRefresh'

  infiniteScroll: ->
    if @more()
      @startLoading('.more')
      @displayMore()
