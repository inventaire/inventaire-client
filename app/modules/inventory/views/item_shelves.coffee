{ addItems, removeItems } = require 'modules/shelves/lib/shelves'
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
    @mainUserIsOwner = app.user.id is @model.get('owner')

  isSelected: ->
    { @item, @selectedShelves } = @options
    @itemCreationMode = @selectedShelves?
    if @itemCreationMode
      @_isSelected = @model.id in @selectedShelves
    else
      @_isSelected = @item.isInShelf(@model.id)
    return @_isSelected

  serializeData: -> _.extend @model.toJSON(),
    isSelected: @_isSelected
    mainUserIsOwner: @mainUserIsOwner

  toggleShelfSelector: ->
    { id } = @model
    if @mainUserIsOwner
      @_isSelected = not @_isSelected
      unless @itemCreationMode
        if @_isSelected
          addItems @model, [ @item ]
        else
          removeItems @model, [ @item ]
      @render()
    else
      app.execute 'show:shelf', @model

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
