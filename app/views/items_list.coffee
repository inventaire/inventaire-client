module.exports = class ItemsList extends Backbone.Marionette.CollectionView
  childView: require 'views/item_li'
  emptyView: require 'views/no_item'
  initialize: ->
    console.log 'initialize items_list'