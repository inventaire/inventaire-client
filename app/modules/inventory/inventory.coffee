ItemShow = require './views/item_show'
initFilters = require './lib/filters'
InventoryLayout = require './views/inventory'
ItemCreationForm = require './views/form/item_creation'
AddLayout = require './views/add/add_layout'
initLayout = require './lib/layout'
initTransactions = require './lib/transactions'
initAddHelpers = require './lib/add_helpers'
ItemsList = require './views/items_list'
{ publicByUsernameAndEntity, publicById, usersPublicItems } = app.API.items

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
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
        'add/import(/)': 'showImport'
        'groups/:id(/:name)(/)': 'showGroupInventory'
        'g/(:name)': 'shortCutGroup'
        'u/(:username)': 'shortCutUser'

    app.addInitializer ->
      new InventoryRouter
        controller: API


  initialize: ->
    app.items = require('./items_collections')(app, _)
    app.request('waitForUserData').then fetchItems.bind(null, app)
    initFilters app
    initTransactions app.items
    initializeInventoriesHandlers app
    initAddHelpers()
    initLayout app

API =
  showGeneralInventory: ->
    if app.request 'require:loggedIn', 'inventory'
      showInventory { generalInventory: true }

  showGeneralInventoryNavigate: ->
    API.showGeneralInventory()
    app.navigate 'inventory'

  showUserInventory: (user, navigate)->
    showInventory
      user: user
      navigate: navigate

  showGroupInventory: (id, name, navigate)->
    showInventory
      group: id
      navigate: navigate

  showInventoryNearby: ->
    if app.request 'require:loggedIn', 'inventory/nearby'
      showInventory { nearby: true }

  showInventoryLast: ->
    if app.request 'require:loggedIn', 'inventory/last'
      showInventory { last: true }

  showItemCreationForm: (options)->
    form = new ItemCreationForm options
    app.layout.main.show form

  showItemFromId: (id)->
    unless _.isItemId id then return app.execute 'show:404'
    app.execute 'show:loader'

    findItemById id
    .then showItemShowFromModel
    .catch (err)->
      if err.status is 404 then app.execute 'show:404'
      else _.error err, 'showItemFromId'

  showUserItemsByEntity: (username, entity, label)->
    unless _.isUsername(username) and _.isEntityUri(entity)
      return app.execute 'show:404'

    app.execute 'show:loader', {title: "#{label} - #{username}"}

    fetchEntityData entity
    .then -> app.request 'waitForItems'
    .then -> findItemByUsernameAndEntity username, entity
    .then displayFoundItems
    .catch _.Error('showItemShowFromUserAndEntity')

  removeUserItems: (userId)->
    _.log userId, 'removeUserItems'
    userItems = app.items.byOwner(userId)
    if userItems?.length > 0 then app.items.remove userItems

  showSearch: -> showAddLayout 'search'
  showScan: -> showAddLayout 'scan'
  showImport: -> showAddLayout 'import'

  shortCutGroup: (name)->
    name = _.softDecodeURI name
    # initGroupHelpers, during which 'group:search:byName'
    # is initialized, runs after waitForUserData
    app.request 'waitForUserData'
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

  shortCutUser: (username)-> API.showUserInventory username, true

showAddLayout = (tab='search')->
  view = new AddLayout { tab: tab }
  titleKey = "title_add_layout_#{tab}"
  app.layout.main.Show view, _.I18n(titleKey)

groupNameMatch = (name, model)->
  model.get('name').toLowerCase() is name

findItemById = (itemId)->
  app.request 'waitForItems'
  .then app.items.byId.bind(app.items, itemId)
  .then (item)->
    if item? then item
    else
      # if it isnt in friends id, it should be a public item
      _.preq.get publicById(itemId)
      .then app.items.public.add
  .catch _.ErrorRethrow('findItemById err (maybe the item was deleted or its visibility changed?)')

fetchEntityData = (entity)->
  # make sure entity model is accessible from Entities.byUri
  app.request 'get:entity:model', entity

# returns both sync value and promises
# => to be called from within a promise chain only
findItemByUsernameAndEntity = (username, entity)->
  owner = app.request 'get:userId:from:username', username
  if app.request 'user:isPublicUser', owner
    return requestPublicItem username, entity
  else
    return app.items.where {owner: owner, entity: entity}

displayFoundItems = (items)->
  _.log items, 'displayFoundItems items'
  unless items?.length?
    throw new Error 'shouldnt be at least an empty array here?'

  switch items.length
    when 0 then app.execute 'show:404'
    # redirect to the item
    when 1 then showItemShowFromModel items[0]
    else showItemsList items

showInventory = (options)->
  app.layout.main.show new InventoryLayout(options)

showItemsList = (items)->
  collection = new Backbone.Collection items
  app.layout.main.show new ItemsList {collection: collection}

# LOGIC
fetchItems = (app)->
  if app.user?.loggedIn
    app.items.fetch({reset: true})
    .always triggerItemsReady
  else
    _.log 'user isnt logged in. not fetching items'
    triggerItemsReady()

  app.reqres.setHandlers
    'item:create': itemCreate
    'items:count:byEntity': itemsCountByEntity

triggerItemsReady = ->
  app.items.personal.fetched = true
  app.user.itemsFetched = true
  app.vent.trigger 'items:ready'

requestPublicItem = (username, entity)->
  _.preq.get publicByUsernameAndEntity(username, entity)
  .then (res)->
    app.execute 'users:public:add', res.user
    return app.items.public.add res.items
  .catch _.Error('requestPublicItem err')

itemCreate = (itemData)->
  unless itemData.title? and itemData.title isnt ''
    throw new Error('cant create item: missing title')

  # will be confirmed by the server
  itemData.owner = app.user.id

  itemModel = app.items.add itemData
  _.preq.resolve itemModel.save()
  .then _.Log('item creation server res')
  .then itemModel.onCreation.bind(itemModel)
  .catch _.Error('item creation err')

  return itemModel

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

    'show:item:creation:form': (params)->
      {entity} = params
      unless entity? then throw new Error 'missing entity'
      uri = entity.get 'uri'
      entityPathname = params.entity.get 'pathname'
      pathname = "#{entityPathname}/add"

      if app.request 'require:loggedIn', pathname
        API.showItemCreationForm params
        # Remove the final add part so that hitting reload or previous
        # reloads the entity page instead of the creation form,
        # avoiding to create undesired item dupplicates
        app.navigate pathname.replace(/\/add$/, '')

    'show:item:show:from:model': showItemShowFromModel

    'show:add:layout': showAddLayout

    'inventory:remove:user:items': (userId)->
      # delay the action to avoid to get a ViewDestroyedError on UserLi
      # caused by the item counter trying to update
      setTimeout API.removeUserItems.bind(null, userId), 0

    'show:inventory:nearby': API.showInventoryNearby
    'show:inventory:last': API.showInventoryLast
    'show:items': displayFoundItems

  app.reqres.setHandlers
    'item:update': (options)->
      # expects: item, attribute, value
      # OR expects: item, data
      # optional: selector
      {item, attribute, value, data, selector} = options
      _.types [item, selector], ['object', 'string|undefined']

      if data?
        _.type data, 'object'
        item.set data
      else
        _.type attribute, 'string'
        item.set attribute, value

      promise = _.preq.resolve item.save()
      if selector?
        app.request 'waitForCheck',
          promise: promise
          selector: selector
      return promise

    'item:destroy': (options)->
      # requires the ConfirmationModal behavior to be on the view
      # MUST: selector, model with title
      # CAN: next
      {model, selector, next} = options
      _.types [model, selector, next], ['object', 'string', 'function']
      title = model.get('title')

      action = -> model.destroy().then next

      $(selector).trigger 'askConfirmation',
        confirmationText: _.i18n('destroy_item_text', {title: title})
        warningText: _.i18n("this action can't be undone")
        action: action

    'get:item:model': findItemById
    'get:item:model:sync': (id)-> app.items.byId id

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

    'inventory:fetch:users:public:items': (usersIds)->
      if usersIds.length is 0
        _.warn usersIds, 'no user ids, no items fetched'
        return _.preq.resolve []

      _.preq.get usersPublicItems(usersIds)
      .then _.property('items')

    'item:main:user:instances': (entityUri)->
      return app.items.personal.byEntityUri(entityUri)

mainUserPrivateInventoryLength = ->
  app.items.personal.where({listing: 'private'}).length
