NoShelfView = require './no_shelf'

ItemShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/item_shelf_li'

  events:
    'click .shelfSelector': 'shelfSelector'
    'click .shelfLink': 'showShelf'

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

  showShelf: (e)->
    { id:shelf } = e.currentTarget
    app.execute 'show:shelf', shelf

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ItemShelfLi

  childViewOptions: ->
    item: @options.item

  emptyView: NoShelfView
