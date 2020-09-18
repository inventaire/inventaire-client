{ addItems, removeItems } = require 'modules/shelves/lib/shelf'
NoShelfView = require './no_shelf'

ItemShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  className: ->
    base = 'shelfSelector'
    if @isSelected() then base += ' selected'
    return base

  template: require './templates/item_shelf_li'

  events:
    'click': 'toggleShelfSelector'

  initialize: ->

  isSelected: ->
    { @item, @selectedShelves } = @options
    @itemCreationMode = @selectedShelves?
    if @itemCreationMode
      @_isSelected = @model.id in @selectedShelves
    else
      @_isSelected = @item.isInShelf(@model.id)
    return @_isSelected

  serializeData: -> _.extend @model.toJSON(), { isSelected: @_isSelected }

  toggleShelfSelector: ->
    { id } = @model
    @_isSelected = not @_isSelected
    unless @itemCreationMode
      if @_isSelected
        addItems @model, [ @item ]
      else
        removeItems @model, [ @item ]
    @render()

  onRender: ->
    if @isSelected() then @$el.addClass 'selected'
    else @$el.removeClass 'selected'

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ItemShelfLi

  childViewOptions: ->
    item: @options.item
    selectedShelves: @options.selectedShelves

  emptyView: NoShelfView
