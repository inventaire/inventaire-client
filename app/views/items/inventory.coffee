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
    'keyup #itemsTextFilterField': 'executeTextFilter'
    'click #itemsTextFilterButton': 'executeTextFilter'
    'keyup #contactSearchField': 'executeContactSearch'
    'click #contactSearchButton': 'executeContactSearch'

  onShow: ->
    app.inventory.topMenu.show new app.View.InventoriesTabs
    app.commands.execute 'personalInventory'

  executeTextFilter: ->
    app.commands.execute 'textFilter', $('#itemsTextFilterField').val()

  executeContactSearch: ->
    app.commands.execute 'contactSearch', $('#contactSearchField').val()