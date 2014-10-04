module.exports = class inventory extends Backbone.Marionette.LayoutView
  id: 'inventory'
  template: require 'views/items/templates/inventory'
  regions:
    topMenu: '#topmMenu'
    viewTools: '#viewTools'
    itemsView: '#itemsView'
    sideMenu: '#sideMenu'

  initialize: ->
    app.vent.on 'inventory:change', (filterName)->
      switch filterName
        when 'personal'
          app.inventory.viewTools.show new app.View.PersonalInventoryTools
          app.inventory.sideMenu.show new app.View.VisibilityTabs
        when 'network'
          app.inventory.viewTools.show new app.View.ContactsInventoryTools
          app.inventory.sideMenu.show new app.View.Contacts.List {collection: app.filteredContacts}
        when 'public'
          app.inventory.viewTools.show new app.View.ContactsInventoryTools
          app.inventory.sideMenu.empty()

  onShow: ->
    @topMenu.show new app.View.InventoriesTabs

  onDestroy: -> _.log 'inventory view destroyed'