ItemsPreviewList = require './items_preview_list'

module.exports = Marionette.LayoutView.extend
  className: 'itemsPreviewLists'
  template: require './templates/items_preview_lists'

  regions:
    givingRegion: '.giving'
    lendingRegion: '.lending'
    sellingRegion: '.selling'
    inventoryingRegion: '.inventorying'

  initialize: ->
    { @category, itemsModels } = @options
    if itemsModels.length is 0 then return
    @collections = spreadByTransactions itemsModels

  serializeData: ->
    header: headers[@category]

  onShow: ->
    for transaction, collection of @collections
      @["#{transaction}Region"].show new ItemsPreviewList
        transaction: transaction
        collection: collection

spreadByTransactions = (itemsModels)->
  collections = {}
  for itemModel in itemsModels
    transaction = itemModel.get('transaction')
    collections[transaction] or= new Backbone.Collection
    collections[transaction].add itemModel

  return collections

headers =
  network: "in your friends' & groups' inventories"
  public: 'public'
