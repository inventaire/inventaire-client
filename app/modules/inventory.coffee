ItemShow = require 'views/items/item_show'

module.exports =
  define: (Inventory, app, Backbone, Marionette, $, _) ->
    InventoryRouter = Marionette.AppRouter.extend
      appRoutes:
        'inventory(/)': 'goToPersonalInventory'
        'inventory/personal(/)': 'showPersonalInventory'
        'inventory/network(/)': 'showNetworkInventory'
        'inventory/public(/)': 'showPublicInventory'
        'inventory/:user(/)': 'showUserInventory'
        'inventory/:user/:suffix(/:title)(/)': 'itemShow'

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
  goToPersonalInventory: ->
    @showPersonalInventory()
    app.navigateReplace 'inventory/personal'

  showPersonalInventory: ->
    showInventory()
    showItemList(app.filteredItems)
    app.inventory.viewTools.show new app.View.PersonalInventoryTools
    app.execute 'filter:inventory:personal'
    app.execute 'filter:visibility:reset'
    app.inventory.sideMenu.show new app.View.VisibilityTabs

  showNetworkInventory: ->
    showInventory()
    showItemList(app.filteredItems)
    app.execute 'filter:inventory:network'
    app.inventory.viewTools.show new app.View.ContactsInventoryTools
    app.inventory.sideMenu.show new app.View.Contacts.List {collection: app.filteredContacts}

  showPublicInventory: ->
    showInventory()
    app.execute('show:loader', app.inventory.itemsView)
    $.getJSON(app.API.items.public())
    .then (res)->
      _.log res, 'publicItems res'
      # not testing if res has items or users
      # letting the inventory empty view do the job
      app.contacts.add res.users
      app.publicItems = new app.Collection.Items res.items

      showItemList(app.publicItems)
      app.vent.trigger 'inventory:change', 'publicInventory'
      app.inventory.viewTools.show new app.View.ContactsInventoryTools
      app.inventory.sideMenu.empty()
    .fail (err)->
      if err.status is 404
        showItemList()
      else _.logXhrErr(err)
    .done()

  showItemCreationForm: (options)->
    form = new app.View.Items.Creation options
    app.layout.main.show form

  showUserInventory: (user)->
    filterForUser = ->
      owner = app.request('getOwnerFromUsername', user)
      if owner?
        app.execute 'filter:inventory:owner', owner
      else
        _.log [user, owner], 'user not found: you should do some ajax wizzardry to get him'
    if app.contacts.fetched
      filterForUser()
    else
      app.vent.on 'contacts:ready', -> filterForUser()
    showInventory(app.filteredItems)

  itemShow: (username, suffix, label)->
    app.execute('show:loader')
    if app.items.fetched and app.contacts.fetched
      @showItemShow(username, suffix, label)
    else
      app.vent.on 'items:ready', =>
        if app.contacts.fetched
          @showItemShow(username, suffix, label)
      app.vent.on 'contacts:ready', =>
        if app.items.fetched
          @showItemShow(username, suffix, label)

  showItemShow: (username, suffix, label)->
    owner = app.request('getOwnerFromUsername', username)
    itemId = app.request('getItemId', {owner: owner, suffix: suffix})
    if itemId?
      _.log item = app.items.findWhere({_id: itemId}), 'found an item?'
      if item? and item.get('owner') is owner
          return @showItemShowFromItemModel(item)
    app.execute 'show:404'

  showItemShowFromItemModel: (item)->
    itemShow = new ItemShow {model: item}
    app.layout.main.show itemShow

showInventory = ->
  # regions shouldnt be undefined, which can't be tested by "app.inventory?._isShown"
  # so here I just test one of Inventory regions
  unless app.inventory?.itemsView?
    app.inventory = new app.Layout.Inventory
    app.layout.main.show app.inventory

  unless app.inventory?.topMenu?._isShown
    app.inventory.topMenu.show new app.View.InventoriesTabs

showItemList = (collection)->
  itemsList = app.inventory.itemsList = new app.View.ItemsList {collection: collection}
  app.inventory.itemsView.show itemsList


createItemFromEntity = (entityData)-> _.log entityData, 'entityData'


# LOGIC
fetchItems = (app)->
  app.items = new app.Collection.Items
  app.items.fetch({reset: true})
  .done ->
    app.items.fetched = true
    app.vent.trigger 'items:ready'

  app.reqres.setHandlers
    'item:validate:creation': validateCreation
    'getItemId': getItemId


validateCreation = (itemData)->
  _.log itemData, 'itemData at validateCreation'
  if itemData.entity?.label? or (itemData.title? and itemData.title isnt '')
    if itemData.entity?.label?
      itemData.title = itemData.entity.label
    itemModel = app.items.create itemData
    itemModel.username = app.user.get('username')
    return true
  else false

getItemId = (params)->
  if not params.owner? and params.username?
    params.owner = app.request('getOwnerFromUsername', params.username)
  return "#{params.owner}:#{params.suffix}"

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
  app.vent.trigger 'inventory:change', filterName

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

    'show:item:show': (username, suffix, title)->
      API.itemShow(username, suffix)
      if title? then app.navigate "inventory/#{username}/#{suffix}/#{title}"
      else app.navigate "inventory/#{username}/#{suffix}"

    'show:item:show:from:model': (item)->
      API.showItemShowFromItemModel(item)
      pathname = item.pathname
      app.navigate pathname

  app.reqres.setHandlers
    'item:update': (options)->
      # expects: item, attribute, value. optional: selector
      options.item.set(options.attribute, options.value)
      promise = options.item.save()
      if options.selector?
        app.request 'waitForCheck',
          promise: promise
          selector: options.selector
      return promise

    'item:destroy': (options)->
      # requires the ConfirmationModal behavior to be on the view
      # MUST: selector, model with title
      # CAN: next
      $(options.selector).trigger 'askConfirmation',
        confirmationText: _.i18n('destroy_item_text', {title: options.model.get('title')})
        warningText: _.i18n("this action can't be undone")
        actionCallback: (options)->
          promise = options.model.destroy()
          options.next()
          return promise
        actionArgs: options