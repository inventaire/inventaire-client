ItemShow = require './views/item_show'
initQueries = require './lib/queries'
InventoryLayout = require './views/inventory'
InventoryBrowser = require './views/inventory_browser'
AddLayout = require './views/add/add_layout'
EmbeddedScanner = require './views/add/embedded_scanner'
initLayout = require './lib/layout'
initAddHelpers = require './lib/add_helpers'
ItemsList = require './views/items_list'
showItemCreationForm = require './lib/show_item_creation_form'
itemActions = require './lib/item_actions'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'inventory(/)': 'showGeneralInventory'
        'inventory/nearby(/)': 'showInventoryNearby'
        'inventory/last(/)': 'showInventoryLast'
        'inventory/browser(/)': 'showInventoryBrowser'
        'inventory/:username(/)': 'showUserInventory'
        'inventory/:username/:entity(/:title)(/)': 'showUserItemsByEntity'
        'items/:id(/)': 'showItemFromId'
        'items(/)': 'showGeneralInventory'
        'add(/search)(/)': 'showSearch'
        'add/scan(/)': 'showScan'
        'add/scan/embedded(/)': 'showEmbeddedScanner'
        'add/import(/)': 'showImport'
        'g(roups)/:id(/)': 'showGroupInventory'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    initQueries app
    initializeInventoriesHandlers app
    initAddHelpers()
    initLayout app

API =
  showGeneralInventory: ->
    if app.request 'require:loggedIn', 'inventory'
      showInventory()
      # Give focus to the home button so that hitting tab gives focus
      # to the search input
      $('#home').focus()

  showUserInventory: (user, navigate)->
    # User might be a user id or a username
    app.request 'resolve:to:userModel', user
    .then (userModel)-> showInventory { user, navigate }
    .catch app.Execute('show:error')

  showGroupInventory: (id, name, navigate)->
    showInventory { group: id, navigate }

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

  showSearch: -> showAddLayout 'search'
  showScan: -> showAddLayout 'scan'
  showImport: -> showAddLayout 'import'

  showEmbeddedScanner: ->
    if app.request 'require:loggedIn', 'add/scan/embedded'
      if window.hasVideoInput
        # navigate before triggering the view itself has
        # special behaviors on route change
        app.navigate 'add/scan/embedded'
        # showing in main so that requesting another layout destroy this view
        app.layout.main.show new EmbeddedScanner
      else
        API.showScan()

  showInventoryBrowser: ->
    if app.request 'require:loggedIn', 'inventory/browser'
      app.layout.main.show new InventoryBrowser

showAddLayout = (tab = 'search', options = {})->
  if app.request 'require:loggedIn', "add/#{tab}"
    options.tab = tab
    app.layout.main.show new AddLayout options

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

showInventory = (options)->
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

    'show:add:layout': showAddLayout
    # equivalent to the previous one as long as search is the default tab
    # but more explicit
    'show:add:layout:search': API.showSearch

    'show:add:layout:import:isbns': (isbnsBatch)->
      showAddLayout 'import', { isbnsBatch }

    'show:scan': API.showScan

    'show:scanner:embedded': API.showEmbeddedScanner

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
