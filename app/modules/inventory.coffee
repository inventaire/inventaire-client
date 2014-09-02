module.exports =
  define: (Inventory, app, Backbone, Marionette, $, _) ->
    InventoryRouter = Marionette.AppRouter.extend
      appRoutes:
        'inventory': 'goToPersonalInventory'
        'inventory/personal': 'showPersonalInventory'
        'inventory/network': 'showNetworkInventory'
        'inventory/public': 'showPublicInventory'
        'inventory/:user?*queryString': 'userInventoryQuery'
        'inventory/:user': 'showUserInventory'

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
  showPersonalInventory: ->
    showInventory()
    showInventoryTabs()
    app.inventory.viewTools.show new app.View.PersonalInventoryTools
    app.execute 'filter:inventory:personal'
    app.inventory.sideMenu.show new app.View.VisibilityTabs

  showNetworkInventory: ->
    showInventory()
    showInventoryTabs()
    app.execute 'filter:inventory:network'
    app.inventory.viewTools.show new app.View.ContactsInventoryTools
    app.inventory.sideMenu.show new app.View.Contacts.List {collection: app.filteredContacts}

  showPublicInventory: ->
    showInventory()
    showInventoryTabs()
    app.execute 'filter:inventory:public'
    console.log '/!\\ fake publicInventory filter'
    app.inventory.viewTools.show new app.View.ContactsInventoryTools
    app.inventory.sideMenu.empty()

  showItemCreationForm: (params)->
    form = new app.View.Items.Creation params
    app.layout.main.show form

  showUserInventory: (user)->
    filterForUser = ->
      userId = app.request('getIdFromUsername', user)
      if userId?
        app.execute 'filter:inventory:owner', userId
      else
        _.log [user, userId], 'user not found: you should do some ajax wizzardry to get him'
    if app.contacts.fetched
      filterForUser()
    else
      app.vent.on 'contacts:ready', -> filterForUser()
    showInventory()

  userInventoryQuery: (user, queryString)->
    query = _.parseQuery(queryString)
    if query?.action is 'add'
      app.execute 'show:item:personal:settings:fromEntityURI', query.entity

    _.log [arguments, query], 'userInventoryQuery'

showInventory = ->
  # regions shouldnt be undefined, which can't be tested by "app.inventory?._isShown"
  # so here I just test one of Inventory regions
  unless app.inventory?.itemsView?
    app.inventory = new app.Layout.Inventory
    app.layout.main.show app.inventory
  itemsList = app.inventory.itemsList = new app.View.ItemsList {collection: app.filteredItems}
  app.inventory.itemsView.show itemsList

showInventoryTabs = ->
  unless app.inventory?.topMenu?._isShown
    app.inventory.topMenu.show new app.View.InventoriesTabs


createItemFromEntity = (entityData)-> _.log entityData, 'entityData'


# LOGIC
fetchItems = (app)->
  app.items = new app.Collection.Items
  app.items.fetch({reset: true})

  app.reqres.setHandlers
    'item:validateCreation': validateCreation

validateCreation = (itemData)->
  _.log itemData, 'itemData at validateCreation'
  if itemData.entity?.label? or (itemData.title? and itemData.title isnt '')
    if itemData.entity?.label?
      itemData.title = itemData.entity.label
    _.extend itemData, {
      _id: _.idGenerator(6)
      created: new Date()
      owner: app.user.get('_id')
    }
    itemModel = app.items.create itemData
    itemModel.username = app.user.get('username')
    return true
  else false

initializeFilters = (app)->
  app.Filters =
    inventory:
      'personalInventory': {'owner': app.user.get('_id')}
      'networkInventory': (model)-> model.get('owner') isnt app.user.id
      'publicInventory': (model)-> model.get('owner') isnt app.user.id
    visibility:
      'private': {'listing':'private'}
      'contacts': {'listing':'contacts'}
      'public': {'listing':'public'}

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
    app.filteredItems.filterBy 'text', (model)-> model.matches filterExpr
  else
    app.filteredItems.removeFilter 'text'



# VIEWS
initializeInventoriesHandlers = (app)->
  app.commands.setHandlers
    'show:inventory:personal': ->
      API.showPersonalInventory()
      app.navigate 'inventory/personal'

    'show:inventory:network': ->
      API.showNetworkInventory()
      app.navigate 'inventory/network'

    'show:inventory:public': ->
      API.showPublicInventory()
      app.navigate 'inventory/public'

    'show:item:creation:form': (params)->
      API.showItemCreationForm(params)
      if params.entity?
        pathname = params.entity.get 'pathname'
        app.navigate "#{pathname}/add"
      else throw new Error 'missing entity'
