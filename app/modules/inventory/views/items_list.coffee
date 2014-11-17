module.exports = class ItemsList extends Backbone.Marionette.CollectionView
  childView: require './item_li'
  emptyView: require './no_item'
  tagName: 'ul'
  className: 'itemsList jk'