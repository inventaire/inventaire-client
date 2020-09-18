{ addItems, removeItems } = require 'modules/shelves/lib/shelf'
NoShelfView = require './no_shelf'

ItemShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  className: 'shelfSelector'

  template: require './templates/item_shelf_li'

  events:
    'click': 'toggleShelfSelector'

  initialize: ->
    { @item, @selectedShelves } = @options
    @itemCreationMode = @selectedShelves?
    if @itemCreationMode
      @isSelected = @model.id in @selectedShelves
    else
      @isSelected = @item.isInShelf(@model.id)

  serializeData: -> _.extend @model.toJSON(), { @isSelected }

  toggleShelfSelector: ->
    { id } = @model
    @isSelected = not @isSelected
    unless @itemCreationMode
      if @isSelected
        addItems @model, [ @item ]
      else
        removeItems @model, [ @item ]
    @render()

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ItemShelfLi

  childViewOptions: ->
    item: @options.item
    selectedShelves: @options.selectedShelves

  emptyView: NoShelfView
