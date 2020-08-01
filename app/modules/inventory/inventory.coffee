ItemShow = require './views/item_show'
initQueries = require './lib/queries'
InventoryLayout = require './views/inventory_layout'
initLayout = require './lib/layout'
ItemsCascade = require './views/items_cascade'
showItemCreationForm = require './lib/show_item_creation_form'
itemActions = require './lib/item_actions'
{ parseQuery, currentRoute, buildPath } = require 'lib/location'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'inventory(/)': 'showGeneralInventory'
        'inventory/network(/)': 'showNetworkInventory'
        'inventory/public(/)': 'showPublicInventory'
        'inventory/nearby(/)': 'showInventoryNearby'
        'inventory/last(/)': 'showInventoryLast'
        'inventory/:username(/)': 'showUserInventoryFromUrl'
        # 'title' is a legacy parameter
        'inventory/:username/:entity(/:title)(/)': 'showUserItemsByEntity'
        'items/:id(/)': 'showItemFromId'
        'items(/)': 'showGeneralInventory'
        # 'name' is a legacy parameter
        'g(roups)/:id(/:name)(/)': 'showGroupInventory'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    initQueries app
    initializeInventoriesHandlers app
    initLayout app

API =
  showGeneralInventory: ->
    if app.request 'require:loggedIn', 'inventory'
      API.showUserInventory app.user
      # Give focus to the home button so that hitting tab gives focus
      # to the search input
      $('#home').focus()

  showNetworkInventory: ->
    if app.request 'require:loggedIn', 'inventory/network'
      showInventory { section: 'network' }
      app.navigate 'inventory/network'

  showPublicInventory: (options = {})->
    if _.isString options then options = parseQuery options
    { filter } = options
    url = buildPath 'inventory/public', { filter }

    if app.request 'require:loggedIn', url
      showInventory { section: 'public', filter }
      app.navigate url

  showUserInventory: (user, standalone)->
    showInventory { user, standalone }

  showUserInventoryFromUrl: (username)->
    showInventory { user: username, standalone: true }

  showGroupInventory: (group, standalone = true)->
    showInventory { group, standalone }

  showInventoryNearby: ->
    if app.request 'require:loggedIn', 'inventory/nearby'
      showInventory { nearby: true }

  showInventoryLast: ->
    if app.request 'require:loggedIn', 'inventory/last'
      showInventory { last: true }

  showItemFromId: (id)->
    unless _.isItemId id then return app.execute 'show:error:missing'

    app.request 'get:item:model', id
    .then app.Execute('show:item')
    .catch (err)-> app.execute 'show:error', err, 'showItemFromId'

  showUserItemsByEntity: (username, uri, label)->
    unless _.isUsername(username) and _.isEntityUri(uri)
      return app.execute 'show:error:missing'

    title = if label then "#{label} - #{username}" else "#{uri} - #{username}"

    app.execute 'show:loader'
    app.navigate "/inventory/#{username}/#{uri}", { metadata: { title } }

    app.request 'get:userId:from:username', username
    .then (userId)-> app.request 'items:getByUserIdAndEntities', userId, uri
    .then showItemsFromModels
    .catch _.Error('showItemShowFromUserAndEntity')

showItemsFromModels = (items)->
  # Accept either an items collection or an array of items models
  if _.isArray items then items = new Backbone.Collection items

  unless items?.length?
    throw new Error 'shouldnt be at least an empty array here?'

  switch items.length
    when 0 then app.execute 'show:error:missing'
    # redirect to the item
    when 1 then showItemModal items.models[0]
    else showItemsList items

showInventory = (options = {})->
  app.layout.main.show new InventoryLayout(options)

showItemsList = (collection)-> app.layout.main.show new ItemsCascade { collection }

showItemModal = (model)->
  previousRoute = currentRoute()
  # Do not scroll top as the modal might be displayed down at the level
  # where the item show event was triggered
  app.navigateFromModel model, { preventScrollTop: true }
  newRoute = currentRoute()

  navigateAfterModal = ->
    if currentRoute() isnt newRoute then return
    if previousRoute is newRoute
      return app.execute 'show:inventory:user', model.get('owner')
    app.navigate previousRoute, { preventScrollTop: true }

  # Let the time to other callbacks to call a navigation before testing if the route
  # should be recovered
  app.vent.once 'modal:closed', -> setTimeout navigateAfterModal, 10

  model.grabWorks()
  .then -> app.layout.modal.show new ItemShow { model }

initializeInventoriesHandlers = (app)->
  app.commands.setHandlers
    'show:inventory': showInventory
    'show:inventory:section': (section)->
      switch section
        when 'user' then API.showUserInventory app.user
        when 'network' then API.showNetworkInventory()
        when 'public' then API.showPublicInventory()
        else throw error_.new 'unknown section', 400, { section }

    'show:inventory:network': API.showNetworkInventory
    'show:inventory:public': API.showPublicInventory

    'show:users:nearby': -> API.showPublicInventory { filter: 'users' }
    'show:groups:nearby': -> API.showPublicInventory { filter: 'groups' }

    # user can be either a username or a user model
    'show:inventory:user': (user)->
      API.showUserInventory user, true

    'show:inventory:main:user': ->
      API.showUserInventory app.user, true

    'show:inventory:group': API.showGroupInventory

    'show:inventory:group:byId': (params)->
      { groupId, standalone } = params
      app.request 'get:group:model', groupId
      .then (group)-> API.showGroupInventory group, standalone
      .catch app.Execute('show:error')

    'show:item:creation:form': showItemCreationForm

    'show:item': showItemModal
    'show:item:byId': API.showItemFromId

    'show:inventory:nearby': API.showInventoryNearby
    'show:inventory:last': API.showInventoryLast

  app.reqres.setHandlers
    'items:update': itemActions.update
    'items:delete': itemActions.delete
    'item:create': itemActions.create
    'item:main:user:instances': (entityUri)->
      app.request 'items:getByUserIdAndEntities', app.user.id, entityUri
      .get 'models'
    'item:update:entity': (item, entity)->
      itemActions.update
        item: item
        attribute: 'entity'
        value: entity.get('uri')
      # Let some time to the server to update the item snapshot data
      .delay 500
      # before requesting an updated item
      .then -> app.request 'get:item:model', item.get('_id')
      .then (updatedItem)-> app.execute 'show:item', updatedItem
