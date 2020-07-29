ItemsPreviewList = require './items_preview_list'
screen_ = require 'lib/screen'

module.exports = Marionette.LayoutView.extend
  className: ->
    className = 'itemsPreviewLists'
    if @options.compact then className += ' compact'
    unless @options.itemsModels?.length > 0 then className += ' emptyLists'
    return className

  template: require './templates/items_preview_lists'

  regions:
    givingRegion: '.giving'
    lendingRegion: '.lending'
    sellingRegion: '.selling'
    inventoryingRegion: '.inventorying'

  initialize: ->
    { @category, @itemsModels, @compact, @displayItemsCovers } = @options
    @itemsWithPositionCount = @itemsModels?.filter((item)-> item.hasPosition()).length or 0
    if @itemsModels?.length > 0
      @collections = spreadByTransactions @itemsModels
    else
      @emptyList = true

  serializeData: ->
    header: headers[@category]
    emptyList: @emptyList
    canShowOnMap: not @emptyList and @itemsWithPositionCount > 0

  events:
    'click .showOnMap': 'showOnMap'

  onShow: ->
    unless @emptyList then @showItemsPreviewLists()

  showItemsPreviewLists: ->
    for transaction, collection of @collections
      @["#{transaction}Region"].show new ItemsPreviewList {
        transaction,
        collection,
        @displayItemsCovers,
        @compact
      }

  showOnMap: ->
    unless @_itemsPositionsSet
      @itemsModels.forEach (model)-> model.position = model.user?.get('position')
      @_itemsPositionsSet = true
    # Add the main user to the list to make sure the map shows their position
    app.execute 'show:models:on:map', @itemsModels.concat([ app.user ])

spreadByTransactions = (itemsModels)->
  collections = {}
  for itemModel in itemsModels
    transaction = itemModel.get('transaction')
    collections[transaction] or= new Backbone.Collection
    collections[transaction].add itemModel

  return collections

headers =
  personal:
    label: 'in your inventory'
    icon: 'user'
  network:
    label: "in your friends' and groups' inventories"
    icon: 'users'
  public:
    label: 'public'
    icon: 'globe'
  nearbyPublic:
    label: 'nearby'
    icon: 'map-marker'
  otherPublic:
    label: 'elsewhere'
    icon: 'globe'
