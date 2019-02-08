InfiniteScrollItemsList = require './infinite_scroll_items_list'
masonryPlugin = require 'modules/general/plugins/masonry'

module.exports = InfiniteScrollItemsList.extend
  className: 'items-cascade-wrapper'
  template: require './templates/items_cascade'
  childViewContainer: '.itemsCascade'
  childView: require './item_card'
  emptyView: require './no_item'

  ui:
    itemsCascade: '.itemsCascade'

  childViewOptions: ->
    showDistance: @options.showDistance

  initialize: ->
    @initInfiniteScroll()

    masonryPlugin.call @, '.itemsCascade', '.itemContainer'

  serializeData: ->
    header: @options.header

  collectionEvents:
    'filtered:add': 'lazyMasonryRefresh'

  childEvents:
    'render': 'lazyMasonryRefresh'
    'resize': 'lazyMasonryRefresh'
