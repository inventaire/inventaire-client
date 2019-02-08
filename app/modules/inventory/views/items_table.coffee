InfiniteScrollItemsList = require './infinite_scroll_items_list'

module.exports = InfiniteScrollItemsList.extend
  className: 'items-table'
  template: require './templates/items_table'
  childView: require './item_row'
  emptyView: require './no_item'
  childViewContainer: 'ul'

  initialize: ->
    @initInfiniteScroll()
