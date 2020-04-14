{ addItems, removeItems } = require 'modules/shelves/lib/shelf'
NoShelfView = require './no_shelf'

ItemShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/item_shelf_li'

  events:
    'click .shelfSelector': 'shelfSelector'

  initialize: ->
    { @item } = @options
    @model.set 'isInShelf', @item.isInShelf(@model.id)

  shelfSelector: ->
    { id } = @model
    if @item.isInShelf id
      removeItems(@model, [ @item ])
    else
      addItems(@model, [ @item ])
    @render()

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ItemShelfLi

  childViewOptions: ->
    item: @options.item

  emptyView: NoShelfView
