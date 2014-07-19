module.exports = (module, app, Backbone, Marionette, $, _) ->
  # LOGIC
  app.Filters =
    inventory:
      'personalInventory': {'owner': app.user.get('username')}
      'networkInventories': {'owner':'zombo'}
      'publicInventories': {'owner':'notUsername'}
    visibility:
      'private': {'visibility':'private'}
      'contacts': {'visibility':'contacts'}
      'public': {'visibility':'public'}

  fetchItems(app)
  initializeFilters(app)
  initializeTextFilter(app)

  # VIEWS
  showInventory(app)
  initializeInventoriesHandlers(app)


# LOGIC

fetchItems = (app)->
  app.items = new app.Collection.Items
  app.items.fetch({reset: true})

initializeFilters = (app)->
  app.filteredItems = new FilteredCollection app.items
  app.commands.setHandler 'filter:inventory', filterInventoryBy
  app.commands.setHandler 'filter:visibility', filterVisibilityBy
  app.commands.setHandler 'filter:visibility:reset', resetVisibilityFilter

filterInventoryBy = (filterName)->
  filters = app.Filters.inventory
  if _.has(filters, filterName)
    otherFilters = _.without _.keys(filters), filterName
    otherFilters.forEach (otherFilterName)->
      app.filteredItems.removeFilter otherFilterName
    app.filteredItems.filterBy filterName, filters[filterName]
  else
    console.error 'invalid filter name'

filterVisibilityBy = (audience)->
  filters = app.Filters.visibility
  if _.has(filters, audience)
    otherFilters = _.without _.keys(filters), audience
    otherFilters.forEach (otherFilterName)->
      app.filteredItems.removeFilter otherFilterName
    app.filteredItems.filterBy audience, filters[audience]
  else
    console.error 'invalid filter name'

resetVisibilityFilter = ->
  _.keys(app.Filters.visibility).forEach (filterName)->
    app.filteredItems.removeFilter filterName

initializeTextFilter = (app)->
  app.commands.setHandler 'textFilter', textFilter

textFilter = (text)->
  if text.length != 0
    filterExpr = new RegExp text, "i"
    app.filteredItems.filterBy 'text', (model)->
      return model.matches filterExpr
  else
    app.filteredItems.removeFilter 'text'



# VIEWS
showInventory = (app)->
  app.inventory = new app.View.Inventory
  app.layout.main.show app.inventory

initializeInventoriesHandlers = (app)->
  app.commands.setHandler 'personalInventory', ->
    app.commands.execute 'filter:visibility:reset'
    app.inventory.viewTools.show new app.View.PersonalInventoryTools
    app.inventory.itemsList = itemsList = new app.View.ItemsList {collection: app.filteredItems}
    app.inventory.itemsView.show itemsList
    app.inventory.sideMenu.show new app.View.VisibilityTabs

  app.commands.setHandler 'networkInventories', ->
    console.log '/!\\ fake networkInventories filter'
    app.inventory.viewTools.show new app.View.ContactsInventoriesTools
    app.inventory.sideMenu.show new app.View.Contacts.List({collection: app.contactsFilteredSearchResults})

  app.commands.setHandler 'publicInventories', ->
    console.log '/!\\ fake publicInventories filter'
    app.inventory.viewTools.show new app.View.ContactsInventoriesTools
    app.inventory.sideMenu.empty()