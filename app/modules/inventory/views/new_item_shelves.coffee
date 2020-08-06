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
    @model.set 'isInShelf', (@id in @shelves)

  shelfSelector: ->
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

  childViewOptions: ->
    item: @item

  emptyView: NoShelfView
