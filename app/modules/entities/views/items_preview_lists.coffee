ItemsPreviewList = require './items_preview_list'
screen_ = require 'lib/screen'

module.exports = Marionette.LayoutView.extend
  className: ->
    className = 'itemsPreviewLists'
    if @options.compact then className += ' compact'
    if @options.itemsModels.length is 0 then className += ' emptyLists'
    return className

  template: require './templates/items_preview_lists'

  regions:
    givingRegion: '.giving'
    lendingRegion: '.lending'
    sellingRegion: '.selling'
    inventoryingRegion: '.inventorying'

  ui:
    detailsTogglers: '.detailsTogglers a'

  initialize: ->
    { @category, itemsModels, @compact } = @options
    if itemsModels.length is 0
      @emptyList = true
    else
      @collections = spreadByTransactions itemsModels

  serializeData: ->
    header: headers[@category]
    emptyList: @emptyList

  onShow: ->
    unless @emptyList then @showItemsPreviewLists false

  events:
    'click .showDetails': 'showDetails'
    'click .hideDetails': 'hideDetails'

  # Re-rendering all the children view might be sub-optimal
  # but I couldn't figure-out how to pass them an event properly
  # and everything would have to be re-drawn anyway
  showDetails: ->
    @showItemsPreviewLists true
    @ui.detailsTogglers.toggleClass 'hidden'

  hideDetails: ->
    @showItemsPreviewLists false
    @ui.detailsTogglers.toggleClass 'hidden'
    # Scroll back at the top to avoid jumping
    # somewhere at the middle of what stands below
    screen_.scrollTop @$el, 0

  showItemsPreviewLists: (showDetails)->
    if showDetails then @$el.addClass 'show-details'
    else @$el.removeClass 'show-details'

    for transaction, collection of @collections
      @["#{transaction}Region"].show new ItemsPreviewList
        transaction: transaction
        collection: collection
        showDetails: showDetails

spreadByTransactions = (itemsModels)->
  collections = {}
  for itemModel in itemsModels
    transaction = itemModel.get('transaction')
    collections[transaction] or= new Backbone.Collection
    collections[transaction].add itemModel

  return collections

headers =
  personal: 'in your inventory'
  network: "in your friends' and groups' inventories"
  public: 'public'
  nearbyPublic: 'nearby'
  otherPublic: 'elsewhere'
