ItemShow = require './views/item_show'
initFilters = require './lib/filters'
initQueries = require './lib/queries'
InventoryLayout = require './views/inventory'
AddLayout = require './views/add/add_layout'
EmbeddedScanner = require './views/add/embedded_scanner'
initLayout = require './lib/layout'
initTransactions = require './lib/transactions'
initAddHelpers = require './lib/add_helpers'
ItemsList = require './views/items_list'
showItemCreationForm = require './lib/show_item_creation_form'
itemActions = require './lib/item_actions'
fetchData = require 'lib/data/fetch'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    InventoryRouter = Marionette.AppRouter.extend
      appRoutes:
        'inventory(/)': 'showGeneralInventory'
        'inventory/nearby': 'showInventoryNearby'
        'inventory/last': 'showInventoryLast'
        'inventory/:username(/)': 'showUserInventory'
        'inventory/:username/:entity(/:title)(/)': 'showUserItemsByEntity'
        'items/:id(/)': 'showItemFromId'
        'items(/)': 'showGeneralInventoryNavigate'
        'add(/search)(/)': 'showSearch'
        'add/scan(/)': 'showScan'
        'add/scan/embedded(/)': 'showEmbeddedScanner'
        'add/import(/)': 'showImport'
        'groups/:id(/:name)(/)': 'showGroupInventory'
        'g/(:name)': 'shortCutGroup'
        'u(ser)(s)/:id': 'shortCutUser'

    app.addInitializer ->
      new InventoryRouter
        controller: API


  initialize: ->
    app.items = require('./items_collections')(app, _)
    initFilters app
    initQueries app
    initTransactions app.items
    initializeInventoriesHandlers app
    initAddHelpers()
    initLayout app

API =
  showGeneralInventory: ->
    if app.request 'require:loggedIn', 'inventory'
      showInventory
        generalInventory: true
        waitForData: app.request 'fetchNetworkItems'

  showGeneralInventoryNavigate: ->
    API.showGeneralInventory()
    app.navigate 'inventory'

  showUserInventory: (user, navigate)->
    # User might be a user id or a username
    app.request 'resolve:to:userModel', user
    .then (userModel)->
      showInventory
        user: user
        navigate: navigate
        waitForData: app.request 'items:fetchByUsers', [ userModel.id ]

  showGroupInventory: (id, name, navigate)->
    app.request 'get:group:model', id
    .then (group)->
      showInventory
        group: id
        navigate: navigate
        waitForData: app.request 'items:fetchByUsers', group.allMembersIds()

  showInventoryNearby: ->
    if app.request 'require:loggedIn', 'inventory/nearby'
      showInventory { nearby: true }

  showInventoryLast: ->
    if app.request 'require:loggedIn', 'inventory/last'
      showInventory { last: true }

  showItemFromId: (id)->
    unless _.isItemId id then return app.execute 'show:error:missing'
    app.execute 'show:loader'

    app.request 'items:getById', id
    .then showItemShowFromModel
    .catch (err)->
      if err.status is 404 then app.execute 'show:error:missing'
      else _.error err, 'showItemFromId'

  showUserItemsByEntity: (username, uri, label)->
    unless _.isUsername(username) and _.isEntityUri(uri)
      return app.execute 'show:error:missing'

    title = if label then "#{label} - #{username}" else "#{uri} - #{username}"
    app.execute 'show:loader', { title }

    app.request 'items:getByUsernameAndEntity', username, uri
    .then displayFoundItems
    .catch _.Error('showItemShowFromUserAndEntity')

  removeUserItems: (userId)->
    _.log userId, 'removeUserItems'
    userItems = app.items.byOwner(userId)
    if userItems?.length > 0 then app.items.remove userItems

  showSearch: -> showAddLayout 'search'
  showScan: -> showAddLayout 'scan'
  showImport: -> showAddLayout 'import'

  showEmbeddedScanner: ->
    if app.request 'require:loggedIn', 'add/scan/embedded'
      if window.hasVideoInput
        # showing in main so that requesting another layout destroy this view
        app.layout.main.show new EmbeddedScanner
      else
        API.showScan()

  shortCutGroup: (name)->
    name = _.softDecodeURI name
    # initGroupHelpers, during which 'group:search:byName'
    # is initialized, runs after waitFor user
    app.request 'wait:for', 'user'
    # make sure this runs after initGroupHelpers
    .delay 100
    # search group by name
    .then -> app.request 'group:search:byName', name
    .then (collection)->
      match = collection.models.filter groupNameMatch.bind(null, name)
      # if found, show group
      if match.length is 1 then showGroupInventory match[0]
      # else show group search
      else app.execute 'show:group:search', name
    .catch _.Error('searchGroup err')

  shortCutUser: (usernameOrId)-> API.showUserInventory usernameOrId, true

showAddLayout = (tab='search')->
  view = new AddLayout { tab: tab }
  titleKey = "title_add_layout_#{tab}"
  app.layout.main.Show view, _.I18n(titleKey)

groupNameMatch = (name, model)->
  model.get('name').toLowerCase() is name

fetchEntityData = (entity)->
  # make sure entity model is accessible from Entities.byUri
  app.request 'get:entity:model', entity

displayFoundItems = (items)->
  _.log items, 'displayFoundItems items'
  unless items?.length?
    throw new Error 'shouldnt be at least an empty array here?'

  switch items.length
    when 0 then app.execute 'show:error:missing'
    # redirect to the item
    when 1 then showItemShowFromModel items[0]
    else showItemsList items

showInventory = (options)->
  app.layout.main.show new InventoryLayout(options)

showItemsList = (items)->
  collection = new Backbone.Collection items
  app.layout.main.show new ItemsList {collection: collection}

itemsCountByEntity = (uri)->
  app.items.where({entity: uri}).length

showGroupInventory = (group)->
  API.showGroupInventory group.id, group.get('name'), true

showItemShowFromModel = (item)->
  app.layout.main.show new ItemShow {model: item}
  if item.pathname? then app.navigate item.pathname
  else _.error item, 'missing item.pathname'

initializeInventoriesHandlers = (app)->
  app.commands.setHandlers
    'show:inventory:general': API.showGeneralInventoryNavigate

    # user can be either a username or a user model
    'show:inventory:user': (user)->
      API.showUserInventory user, true

    'show:inventory:main:user': ->
      API.showUserInventory app.user, true

    'show:inventory:group': showGroupInventory

    'show:inventory:group:byId': (groupId)->
      group = app.request 'get:group:model:sync', groupId
      showGroupInventory group

    'show:item:creation:form': showItemCreationForm

    'show:item:show:from:model': showItemShowFromModel

    'show:add:layout': showAddLayout
    # equivalent to the previous one as long as search is the default tab
    # but more explicit
    'show:add:layout:search': API.showSearch
    # show the last search if it can be found
    # else show the add_layout search tab
    'show:add:layout:search:last': ->
      lastSearch = app.searches.findLastSearch()
      if lastSearch? then lastSearch.show()
      else API.showSearch()

    'show:scan': -> API.showScan()

    'show:scanner:embedded': ->
      # navigate before triggering the view itself has
      # special behaviors on route change
      app.navigate 'add/scan/embedded'
      API.showEmbeddedScanner()

    'inventory:remove:user:items': (userId)->
      # delay the action to avoid to get a ViewDestroyedError on UserLi
      # caused by the item counter trying to update
      setTimeout API.removeUserItems.bind(null, userId), 0

    'show:inventory:nearby': API.showInventoryNearby
    'show:inventory:last': API.showInventoryLast
    'show:items': displayFoundItems

  app.reqres.setHandlers
    'item:update': itemActions.update
    'item:destroy': itemActions.destroy
    'item:create': itemActions.create

    'items:count:byEntity': itemsCountByEntity

    # Aliasing
    'get:item:model': app.Request 'items:getById'

    'inventory:main:user:length': (nonPrivate)->
      fullInventoryLength = app.items.personal.length
      privateInventoryLength = mainUserPrivateInventoryLength()
      if nonPrivate then fullInventoryLength - privateInventoryLength
      else fullInventoryLength

    'inventory:user:length': (userId)->
      # app.items.where({owner: userId}).length would be simpler
      # but probably less efficient?
      return app.items.inventoryLength[userId]

    'inventory:user:items': (userId)->
      return app.items.where({owner: userId})

    'item:main:user:instances': (entityUri)->
      return app.items.personal.byEntityUri(entityUri)

mainUserPrivateInventoryLength = ->
  app.items.personal.where({listing: 'private'}).length
