behaviorsPlugin = require 'modules/general/plugins/behaviors'
paginationPlugin = require 'modules/general/plugins/pagination'
masonryPlugin = require 'modules/general/plugins/masonry'
itemsPerPage = require 'modules/inventory/lib/items_per_pages'

module.exports = Backbone.Marionette.CompositeView.extend
  className: 'itemsListWrapper'
  template: require './templates/items_list'
  childViewContainer: '.itemsList'
  childView: require './item_figure'
  emptyView: require './no_item'
  behaviors:
    Loading: {}

  ui:
    itemsList: '.itemsList'

  initialize: ->
    @initPlugins()

  initPlugins: ->
    _.extend @, behaviorsPlugin
    paginationPlugin.call @, itemsPerPage()
    masonryPlugin.call @, 'itemsList', '.itemContainer'

  events:
    'inview .more': 'infiniteScroll'

  collectionEvents:
    'render': 'stopLoading'

  infiniteScroll: ->
    if @more()
      @startLoading('.more')
      @displayMore()
