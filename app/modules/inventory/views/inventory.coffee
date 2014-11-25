module.exports = class inventory extends Backbone.Marionette.LayoutView
  id: 'inventory'
  template: require './templates/inventory'
  regions:
    itemsView: '#itemsView'
    sideMenu: '#sideMenu'

  initialize: ->
    app.vent.on 'inventory:change', (filterName)->
      switch filterName
        when 'personal'
          # app.layout.viewTools.empty()
          app.inventory.sideMenu.show new app.View.PersonalInventoryTools
        when 'friends'
          _.log app.users, 'app.users'
          # app.layout.viewTools.show new app.View.FriendsInventoryTools
          app.inventory.sideMenu.show new app.View.Users.List {collection: app.users.friends.filtered}
        when 'public'
          # app.layout.viewTools.empty()
          app.inventory.sideMenu.empty()

  onShow: ->
    app.layout.topMenu.show new app.View.InventoriesTabs
    $('#inventorySections').slideDown(1000)

  onDestroy: ->
    app.layout.topMenu.empty()
    app.layout.viewTools.empty()
    @hideMenuBar()

  toggleMenuBar: -> $('#menuBar').toggle()
  showMenuBar: -> $('#menuBar').show()
  hideMenuBar: -> $('#menuBar').hide()