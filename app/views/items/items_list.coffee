module.exports = class ItemsList extends Backbone.Marionette.CollectionView
  childView: require 'views/items/item_li'
  emptyView: require 'views/items/no_item'
  initialize: ->
    console.log 'initialize items_list'