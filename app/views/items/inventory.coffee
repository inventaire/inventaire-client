module.exports = class Inventory extends Backbone.Marionette.LayoutView
  id: 'inventory'
  template: require 'views/items/templates/inventory'
  regions:
    topMenu: '#topmMenu'
    viewTools: '#viewTools'
    itemsView: '#itemsView'
    sideMenu: '#sideMenu'

  events:
    # not delegated to tools view as used in several ones
    'keyup #itemsTextFilterField': ->
      app.commands.execute 'textFilter', $('#itemsTextFilterField').val()
    'click #itemsTextFilterButton': ->
      app.commands.execute 'textFilter', $('#itemsTextFilterField').val()
    'keyup #contactSearchField': ->
      app.commands.execute 'contactSearch', $('#contactSearchField').val()
    'click #contactSearchButton': ->
      app.commands.execute 'contactSearch', $('#contactSearchField').val()

  onShow: ->
    app.inventory.topMenu.show new app.View.InventoriesTabs
    app.commands.execute 'personalInventory'