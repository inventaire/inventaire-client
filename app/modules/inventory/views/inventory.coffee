InventoryNav = require './inventory_nav'
InventoryBrowser = require './inventory_browser'

module.exports = Marionette.LayoutView.extend
  id: 'inventory'
  template: require './templates/inventory'
  regions:
    inventoryNav: '#inventoryNav'
    itemsList: '#itemsList'

  onShow: ->
    @inventoryNav.show new InventoryNav { user: app.user }
    @itemsList.show new InventoryBrowser { user: app.user }
