module.exports = class inventory extends Backbone.Marionette.LayoutView
  id: 'inventory'
  template: require 'views/items/templates/inventory'
  regions:
    itemsView: '#itemsView'
    sideMenu: '#sideMenu'

  initialize: ->
    app.vent.on 'inventory:change', (filterName)->
      switch filterName
        when 'personal'
          # app.layout.viewTools.empty()
          app.inventory.sideMenu.show new app.View.PersonalInventoryTools
        when 'network'
          # app.layout.viewTools.show new app.View.ContactsInventoryTools
          app.inventory.sideMenu.show new app.View.Contacts.List {collection: app.filteredContacts}
        when 'public'
          # app.layout.viewTools.empty()
          app.inventory.sideMenu.empty()

  onShow: ->
    app.layout.topMenu.show new app.View.InventoriesTabs

  onDestroy: ->
    app.layout.topMenu.empty()
    app.layout.viewTools.empty()
    @hideMenuBar()

  toggleMenuBar: -> $('#menuBar').toggle()
  showMenuBar: -> $('#menuBar').show()
  hideMenuBar: -> $('#menuBar').hide()