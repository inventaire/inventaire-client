ItemShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/item_shelf_li'

  events:
    'click .shelfSelector': 'shelfSelector'

  initialize: ->
    { @item } = @options
    @model.set 'isItemInShelf', @item.isInShelf(@model.id)

  shelfSelector: ->
    { @item } = @options
    { id } = @model
    if @item.isInShelf id
      @item.deleteShelf id
    else
      @item.addShelf id

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ItemShelfLi

  childViewOptions: ->
    item: @options.item
