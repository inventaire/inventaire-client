ItemShow = require './views/item_show'
initQueries = require './lib/queries'
InventoryLayout = require './views/inventory'
initLayout = require './lib/layout'
ItemsList = require './views/items_list'
showItemCreationForm = require './lib/show_item_creation_form'
itemActions = require './lib/item_actions'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'inventory(/)': 'showGeneralInventory'
        'inventory/network(/)': 'showNetworkInventory'
        'inventory/public(/)': 'showPublicInventory'
        'inventory/nearby(/)': 'showInventoryNearby'
        'inventory/last(/)': 'showInventoryLast'
        'inventory/:username(/)': 'showUserInventory'
        'inventory/:username/:entity(/:title)(/)': 'showUserItemsByEntity'
        'items/:id(/)': 'showItemFromId'
        'items(/)': 'showGeneralInventory'
        'g(roups)/:id(/)': 'showGroupInventory'

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
    showInventory { section: 'network' }
    app.navigate 'inventory/network'

  showPublicInventory: ->
    showInventory { section: 'public' }
    app.navigate 'inventory/public'

  showUserInventory: (user)->
    showInventory { user }

  showGroupInventory: (id, name)->
    showInventory { group: id }

  showInventoryNearby: ->
    if app.request 'require:loggedIn', 'inventory/nearby'
      showInventory { nearby: true }

  showInventoryLast: ->
    if app.request 'require:loggedIn', 'inventory/last'
      showInventory { last: true }

  showItemFromId: (id)->
    unless _.isItemId id then return app.execute 'show:error:missing'
    app.execute 'show:loader'

    app.request 'get:item:model', id
    .then showWorkWithItemModal
    .catch (err)-> app.execute 'show:error', err, 'showItemFromId'

  showUserItemsByEntity: (username, uri, label)->
    unless _.isUsername(username) and _.isEntityUri(uri)
      return app.execute 'show:error:missing'

    title = if label then "#{label} - #{username}" else "#{uri} - #{username}"

    app.execute 'show:loader'
    app.navigate "/inventory/#{username}/#{uri}", { metadata: { title } }

    app.request 'get:userId:from:username', username
    .then (userId)-> app.request 'items:getByUserIdAndEntity', userId, uri
    .then displayFoundItems
    .catch _.Error('showItemShowFromUserAndEntity')


displayFoundItems = (items)->
  # Accept either an items collection or an array of items models
  if _.isArray items then items = new Backbone.Collection items

  unless items?.length?
    throw new Error 'shouldnt be at least an empty array here?'

  switch items.length
    when 0 then app.execute 'show:error:missing'
    # redirect to the item
    when 1 then showWorkWithItemModal items.models[0]
    else showItemsList items

showInventory = (options = {})->
  app.layout.main.show new InventoryLayout(options)

showItemsList = (collection)-> app.layout.main.show new ItemsList { collection }

showGroupInventory = (group)->
  API.showGroupInventory group.id, group.get('name'), true
  app.navigateFromModel group

showWorkWithItemModal = (model)->
  app.execute 'show:work:with:item:modal', model

showItemModal = (model)->
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

    'show:inventory:general': API.showGeneralInventory

    # user can be either a username or a user model
    'show:inventory:user': (user)->
      API.showUserInventory user, true

    'show:inventory:main:user': ->
      API.showUserInventory app.user, true

    'show:inventory:group': showGroupInventory

    'show:inventory:group:byId': (groupId)->
      app.request 'get:group:model', groupId
      .then (group)-> showGroupInventory group
      .catch app.Execute('show:error')

    'show:item:creation:form': showItemCreationForm

    'show:item': showWorkWithItemModal

    'show:inventory:nearby': API.showInventoryNearby
    'show:inventory:last': API.showInventoryLast
    'show:item:modal': showItemModal

  app.reqres.setHandlers
    'item:update': itemActions.update
    'item:destroy': itemActions.destroy
    'item:create': itemActions.create
    'item:main:user:instances': (entityUri)->
      app.request 'items:getByUserIdAndEntity', app.user.id, entityUri
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
