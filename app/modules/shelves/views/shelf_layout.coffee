ShelfModel = require '../models/shelf'
ShelfView = require './shelf'
ShelfItems = require './shelf_items'
Items = require 'modules/inventory/collections/items'
InventoryBrowser = require 'modules/inventory/views/inventory_browser'

error_ = require 'lib/error'

module.exports = Marionette.LayoutView.extend
  id: 'shelvesLayout'
  template: require './templates/shelf_layout'
  regions:
    shelf: '.shelf'
    itemsList: '.itemsList'

  onShow: ->
    { shelf: shelfId } = @options
    Promise.all([ getById(shelfId), @getItemsData(shelfId) ])
    .spread (shelf, itemsData)=>
      _.extend itemsData, { type: shelf }

      user = {}
      if app.user.id is shelf.get('owner')
        user.isMainUser = true

      @shelf.show new ShelfView { model: shelf }
      @itemsList.show new InventoryBrowser { itemsData, shelf, user }
    .catch app.Execute('show:error')

  events:
    'click #editItems': 'showItemsEditor'

  getItemsData: (shelfId) ->
    if shelfId? then params = { shelf: shelfId }
    _.preq.get app.API.items.inventoryView(params)

getById = (id)->
  _.preq.get app.API.shelves.byIds(id)
  .get 'shelves'
  .then (shelves)->
    shelf = Object.values(shelves)[0]
    if shelf? then new ShelfModel shelf
    else throw error_.new 'not found', 404, { id }
