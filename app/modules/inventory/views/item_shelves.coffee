{ addItems, removeItems } = require 'modules/shelves/lib/shelves'
NoShelfView = require './no_shelf'
{ startLoading } = require 'modules/general/plugins/behaviors'

ItemShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  className: ->
    base = 'shelfSelector'
    if @isSelected() then base += ' selected'
    return base

  behaviors:
    Loading: {}

  template: require './templates/item_shelf_li'

  initialize: ->
    { @item, @itemsIds, @selectedShelves } = @options
    @bulkMode = @itemsIds?
    @mainUserIsOwner = app.user.id is @model.get('owner')

  events:
    'click .add': 'add'
    'click .remove': 'remove'
    'click': 'toggleShelfSelector'

  isSelected: ->
    { @item, @selectedShelves } = @options
    unless @item? then return
    @itemCreationMode = @selectedShelves?
    if @itemCreationMode
      @_isSelected = @model.id in @selectedShelves
    else
      @_isSelected = @item.isInShelf(@model.id)
    return @_isSelected

  serializeData: -> _.extend @model.toJSON(),
    isSelected: @_isSelected
    mainUserIsOwner: @mainUserIsOwner
    bulkMode: @bulkMode

  toggleShelfSelector: ->
    if @bulkMode then return

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

  add: ->
    startLoading.call @, '.add .loading'
    addItems @model, @itemsIds
    # TODO: update the inventory state without having to reload
    .then -> window.location.reload()

  remove: ->
    startLoading.call @, '.remove .loading'
    removeItems @model, @itemsIds
    # TODO: update the inventory state without having to reload
    .then -> window.location.reload()

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ItemShelfLi

  childViewOptions: ->
    item: @options.item
    selectedShelves: @options.selectedShelves
    itemsIds: @options.itemsIds

  emptyView: NoShelfView
