{ addItems, removeItems } = require 'modules/shelves/lib/shelf'
NoShelfView = require './no_shelf'

ItemsShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/item_shelf_li'

  events:
    'click .shelfSelector': 'shelfSelector'

  initialize: ->
    { @items } = @options
    @itemsInShelf = @items.filter (item)=> item.isInShelf(@model.id)
    # isInShelf is used by the multi used template item_shelf_li
    # here it express if all selected items are in the shelf
    @model.set 'isInShelf', @areAllItemsInShelf()

  shelfSelector: ->
    if @model.get 'isInShelf'
      removeItems(@model, @items)
    else
      addItems(@model, @items)
    @render()

  areAllItemsInShelf: ->
    @itemsInShelf.length is @items.length

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ItemsShelfLi

  childViewOptions: ->
    items: @options.items

  emptyView: NoShelfView
