module.exports = Backbone.Marionette.CompositeView.extend
  className: 'itemsGrid'
  template: require './templates/items_grid'
  childViewContainer: 'tbody'
  childView: require './item_row'
  emptyView: require './no_item'
