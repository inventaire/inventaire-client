module.exports = (module, app, Backbone, Marionette, $, _) ->
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
  showInventory(app)

fetchItems = (app)->
  app.items = new app.Collection.Items
  app.items.fetch({reset: true})

showInventory = (app)->
  app.inventory = new app.View.Inventory
  app.layout.main.show app.inventory

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