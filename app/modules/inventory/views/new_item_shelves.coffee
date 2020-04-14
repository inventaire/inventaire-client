NoShelfView = require './no_shelf'

NewItemShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/item_shelf_li'

  events:
    'click .shelfSelector': 'shelfSelector'

  initialize: ->
    @model.set 'isInShelf', false

  shelfSelector: ->
    { @item } = @options
    { @shelves } = @item
    { @id } = @model
    if @model.get 'isInShelf'
      @shelves = _.without @shelves, @id
      @model.set 'isInShelf', false
    else
      @shelves.push @id
      @model.set 'isInShelf', true
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
