NoShelfView = require './no_shelf'

NewItemShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/item_shelf_li'

  events:
    'click .shelfSelector': 'shelfSelector'

  initialize: ->
    { @item } = @options
    { @shelves } = @item
    { @id } = @model
    @model.set 'isItemInShelf', false

  shelfSelector: ->
    if @model.get 'isItemInShelf'
      @shelves = _.without @shelves, @id
      @model.set 'isItemInShelf', false
    else
      @shelves.push @id
      @model.set 'isItemInShelf', true
    @render()

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: NewItemShelfLi

  initialize: ->
    { @item } = @options
    @item.shelves = []

  childViewOptions: ->
    item: @item

  emptyView: NoShelfView
