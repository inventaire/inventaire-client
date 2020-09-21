{ addItems, removeItems } = require 'modules/shelves/lib/shelves'
NoShelfView = require './no_shelf'
{ startLoading } = require 'modules/general/plugins/behaviors'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'

ItemShelfLi = Marionette.ItemView.extend
  tagName: 'li'
  className: 'shelfSelector'

  behaviors:
    AlertBox: {}
    Loading: {}

  template: require './templates/item_shelf_li'

  initialize: ->
    { @item, @itemsIds, @selectedShelves, @mainUserIsOwner } = @options
    @itemCreationMode = @selectedShelves?
    @bulkMode = @itemsIds?
    # Init @_isSelected
    @isSelected()

  events:
    'click .add': 'addShelf'
    'click .remove': 'removeShelf'
    'click': 'toggleShelfSelector'

  isSelected: ->
    { @item, @selectedShelves } = @options

    if @selectedShelves?
      # Check @selectedShelves only on first run
      if @_isSelected?
        return @_isSelected
      else
        @_isSelected = @model.id in @selectedShelves
        return @_isSelected
    else if @item?
      @_isSelected = @item.isInShelf(@model.id)
      return @_isSelected

  serializeData: ->
    _.extend @model.toJSON(),
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

  addShelf: ->
    startLoading.call @, '.add .loading'
    addItems @model, @itemsIds
    # TODO: update the inventory state without having to reload
    .then => app.execute 'show:shelf', @model.id
    .catch forms_.catchAlert.bind(null, @)

  removeShelf: ->
    startLoading.call @, '.remove .loading'
    removeItems @model, @itemsIds
    # TODO: update the inventory state without having to reload
    .then => app.execute 'show:shelf', @model.id
    .catch forms_.catchAlert.bind(null, @)

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ItemShelfLi

  serializeData: -> { @mainUserIsOwner }

  childViewOptions: ->
    item: @options.item
    selectedShelves: @options.selectedShelves
    itemsIds: @options.itemsIds
    mainUserIsOwner: @options.mainUserIsOwner

  emptyView: NoShelfView
