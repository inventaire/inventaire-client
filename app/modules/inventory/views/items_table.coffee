module.exports = Marionette.CompositeView.extend
  className: 'items-table'
  template: require './templates/items_table'
  childView: require './item_row'
  emptyView: require './no_item'
  childViewContainer: 'ul'
