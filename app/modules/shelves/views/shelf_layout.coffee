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
    itemsEditor: '.itemsEditor'

  onShow: ->
    { shelf: shelfId } = @options
    getById(shelfId)
    .then (shelf)=>
      @shelf.show new ShelfView { model: shelf }
      @itemsList.show new InventoryBrowser { shelf }
    .catch app.Execute('show:error')

  events:
    'click #editItems': 'showItemsEditor'

getById = (id)->
  _.preq.get app.API.shelves.byIds(id)
  .get 'shelves'
  .then (shelves)->
    shelf = Object.values(shelves)[0]
    if shelf? then new ShelfModel shelf
    else throw error_.new 'not found', 404, { id }
