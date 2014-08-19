module.exports =
  define: (Inventory, app, Backbone, Marionette, $, _) ->
    InventoryRouter = Marionette.AppRouter.extend
      appRoutes:
        'inventory': 'goToPersonalInventory'
        'inventory/personal': 'showPersonalInventory'
        'inventory/network': 'showNetworkInventory'
        'inventory/public': 'showPublicInventory'

    app.addInitializer ->
      new InventoryRouter
        controller: API

  initialize: ->
    # LOGIC
    fetchItems(app)
    initializeFilters(app)
    initializeTextFilter(app)

    # VIEWS
    initializeInventoriesHandlers(app)

API =
  goToPersonalInventory: -> app.goTo 'inventory/personal'
  showPersonalInventory: -> switchInventory 'personal'
  showNetworkInventory: -> switchInventory 'network'
  showPublicInventory: -> switchInventory 'public'

switchInventory = (name)->
  showInventory()
  app.execute "#{name}Inventory"

showInventory = ->
  app.inventoryLayout ||= new app.Layout.Inventory
  unless app.inventoryLayout._isShown
    app.layout.main.show app.inventoryLayout
  app.inventoryLayout.itemsList = itemsList = new app.View.ItemsList {collection: app.filteredItems}
  app.inventoryLayout.itemsView.show itemsList

# LOGIC
fetchItems = (app)->
  app.items = new app.Collection.Items
  app.items.fetch({reset: true})
  app.commands.setHandlers
    'item:create': createItem
    'item:edit': editItem

  app.reqres.setHandlers
    'item:validateCreation': validateCreation

createItem = ()->
  app.layout.item ||= new Object
  form = app.layout.item.creation = new app.View.ItemCreationForm
  app.layout.modal.show form

editItem = (itemModel)->
  app.layout.item ||= new Object
  form = app.layout.item.edition = new app.View.ItemEditionForm {model: itemModel}
  app.layout.modal.show form

validateCreation = (itemData)->
  if itemData.title? && itemData.title isnt ''
    _.extend itemData, {
      _id: _.idGenerator(6)
      created: new Date()
      owner: app.user.get('_id')
    }
    itemModel = app.items.create itemData
    itemModel.username = app.user.get('username')
    return true
  else
    return false

initializeFilters = (app)->
  app.Filters =
    inventory:
      'personalInventory': {'owner': app.user.get('_id')}
      'networkInventory': (model)-> return model.get('owner') isnt app.user.id
      'publicInventory': (model)-> return model.get('owner') isnt app.user.id
    visibility:
      'private': {'visibility':'private'}
      'contacts': {'visibility':'contacts'}
      'public': {'visibility':'public'}

  # user will probably have no id when initializeFilters is fired as the user recover data may not have return yet
  # so we need to listen for this event
  app.user.on 'change:_id', (model, id)->
    app.Filters.inventory.personalInventory.owner = id
    if app.filteredItems.getFilters().indexOf('personalInventory') isnt -1
      app.filteredItems.removeFilter 'personalInventory'
      app.execute 'filter:inventory:personal'

  app.filteredItems = new FilteredCollection app.items
  app.commands.setHandlers
    'filter:inventory:personal': -> filterInventoryBy 'personalInventory'
    'filter:inventory:network': -> filterInventoryBy 'networkInventory'
    'filter:inventory:public': -> filterInventoryBy 'publicInventory'
    'filter:inventory:owner': filterInventoryByOwner
    'filter:visibility': filterVisibilityBy
    'filter:visibility:reset': resetVisibilityFilter

filterInventoryBy = (filterName)->
  app.filteredItems.removeFilter 'owner'
  filters = app.Filters.inventory
  otherFilters = _.without _.keys(filters), filterName
  otherFilters.forEach (otherFilterName)->
    app.filteredItems.removeFilter otherFilterName
  app.filteredItems.filterBy filterName, filters[filterName]
  app.vent.trigger "inventory:change", filterName

filterInventoryByOwner = (ownerId)->
  app.filteredItems.filterBy 'owner', (model)->
    return model.get('owner') is ownerId

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
initializeInventoriesHandlers = (app)->
  app.commands.setHandlers
    'personalInventory': ->
      app.inventoryLayout.viewTools.show new app.View.PersonalInventoryTools
      app.execute 'filter:inventory:personal'
      app.inventoryLayout.sideMenu.show new app.View.VisibilityTabs
      app.navigate 'inventory/personal'

    'networkInventory': ->
      app.execute 'filter:inventory:network'
      app.inventoryLayout.viewTools.show new app.View.ContactsInventoryTools
      app.inventoryLayout.sideMenu.show new app.View.Contacts.List({collection: app.filteredContacts})
      app.navigate 'inventory/network'

    'publicInventory': ->
      app.execute 'filter:inventory:public'
      console.log '/!\\ fake publicInventory filter'
      app.inventoryLayout.viewTools.show new app.View.ContactsInventoryTools
      app.inventoryLayout.sideMenu.empty()
      app.navigate 'inventory/public'
