ShelfItemLi = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/shelf_item_li'

  events:
    'click .itemLi': 'itemSelector'

  initialize: ->
    { @shelf } = @options
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change:shelves', @lazyRender
    @model.set('isItemInShelf', @model.isInShelf @shelf)

  itemSelector: ->
    console.log("##### 15 ##",@model)
    if @model.isInShelf @shelf
      @model.deleteShelf @shelf
    else
      @model.addShelf @shelf

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ShelfItemLi

  childViewOptions: ->
    shelf: @options.shelf
