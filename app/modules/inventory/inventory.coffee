ItemShow = require './views/item_show'
Filters = require './lib/filters'
Transactions = require './lib/transactions'
InventoryLayout = require './views/inventory'
ItemCreationForm = require './views/form/item_creation'
initLayout = require './lib/layout'
AddLayout = require './views/add/add_layout'
initAddHelpers = require './lib/add_helpers'
{ publicByUsernameAndEntity, publicById, usersPublicItems } = app.API.items

module.exports =
  define: (Inventory, app, Backbone, Marionette, $, _) ->
    InventoryRouter = Marionette.AppRouter.extend
      appRoutes:
        'inventory(/)': 'showGeneralInventory'
        'inventory/nearby': 'showInventoryNearby'
        'inventory/last': 'showInventoryLast'
        'inventory/:username(/)': 'showUserInventory'
        'inventory/:username/:entity(/:title)(/)': 'itemShow'
        'add(/)': 'showAddLayout'
        'groups/:id(/:name)(/)': 'showGroupInventory'

    app.addInitializer ->
      new InventoryRouter
        controller: API


  initialize: ->
    window.Items = Items = require('./items_collections')(app, _)
    app.request('waitForUserData').then fetchItems.bind(null, app)
    Filters.initialize(app)
    Transactions(Items)
    initializeInventoriesHandlers(app)
    initAddHelpers()
    initLayout(app)

API =
  showGeneralInventory: ->
    if app.request 'require:loggedIn', 'inventory'
      showInventory { generalInventory: true }

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

  itemShow: (username, entity, label)->
    unless _.isUsername(username) and _.isEntityUri(entity)
      return app.execute 'show:404'

    app.execute 'show:loader', {title: "#{label} - #{username}"}
    app.request 'waitForItems'
    .then @showItemShow.bind(@, username, entity, label)

  showItemShow: (username, entity, label)->
    _.preq.start
    .then @fetchEntityData.bind(@, entity)
    .then @findItemByUsernameAndEntity.bind(@, username, entity)
    .then @displayFoundItems.bind(@)
    .catch _.Error('showItemShow')

  fetchEntityData: (entity)->
    # make sure entity model is accessible from Entities.byUri
    app.request('get:entity:model', entity)

  # returns both sync value and promises
  # => to be called from within a promise chain only
  findItemByUsernameAndEntity: (username, entity)->
    owner = app.request 'get:userId:from:username', username
    if app.request 'user:isPublicUser', owner
      return requestPublicItem username, entity
    else
      return Items.where {owner: owner, entity: entity}

  findItemById: (itemId)->
    app.request('waitForFriendsItems')
    .then Items.byId.bind(Items, itemId)
    .then (item)->
      if item? then item
      else
        # if it isnt in friends id, it should be a public item
        _.preq.get publicById(itemId)
        .then Items.public.add
    .catch _.Error('findItemById err (maybe the item was deleted?)')

  displayFoundItems: (items)->
    _.log items, 'displayFoundItems items'
    unless items?.length?
      throw new Error 'shouldnt be at least an empty array here?'

    switch items.length
      when 0 then app.execute 'show:404'
      when 1 then app.execute 'show:item:show:from:model', items[0]
      else
        console.warn 'multi items not implemented yet'
        app.execute 'show:item:show:from:model', items[0]

  showItemShowFromItemModel: (item)->
    itemShow = new ItemShow {model: item}
    app.layout.main.show itemShow

  removeUserItems: (userId)->
    _.log userId, 'removeUserItems'
    userItems = Items.byOwner(userId)
    if userItems?.length > 0 then Items.remove userItems

  showAddLayout: ->
    app.layout.main.Show new AddLayout, _.I18n('title_add_layout')


showInventory = (options)->
  app.layout.main.show new InventoryLayout(options)


# LOGIC
fetchItems = (app)->
  if app.user?.loggedIn
    Items.fetch({reset: true})
    .always triggerItemsReady
  else
    _.log 'user isnt logged in. not fetching items'
    triggerItemsReady()

  app.reqres.setHandlers
    'item:create': itemCreate
    'items:count:byEntity': itemsCountByEntity

triggerItemsReady = ->
  Items.personal.fetched = true
  app.user.itemsFetched = true
  app.vent.trigger 'items:ready'

requestPublicItem = (username, entity)->
  _.preq.get publicByUsernameAndEntity(username, entity)
  .then (res)->
    app.execute 'users:public:add', res.user
    return Items.public.add res.items
  .catch _.Error('requestPublicItem err')

itemCreate = (itemData)->
  if itemData.entity?.label?
    itemData.title = itemData.entity.label

  unless itemData.title? and itemData.title isnt ''
    throw new Error('cant create item: missing title')

  itemModel = Items.add itemData
  _.preq.resolve itemModel.save()
  .then itemModel.set.bind(itemModel)
  .catch _.Error('item creation err')

  return itemModel

itemsCountByEntity = (uri)->
  Items.where({entity: uri}).length

showGroupInventory = (group)->
  API.showGroupInventory group.id, group.get('name'), true

initializeInventoriesHandlers = (app)->
  app.commands.setHandlers
    'show:inventory:general': ->
      API.showGeneralInventory()
      app.navigate 'inventory'

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
        app.request 'waitForUserData'
        .then ->
          existingInstance = app.request 'item:main:user:instance', uri
          if existingInstance?
            # Inventaire doesn't support having several instances of an item
            # so trying to show the creation form redirects to the existing item
            app.execute 'show:item:show:from:model', existingInstance
          else
            API.showItemCreationForm params
            app.navigate pathname

    'show:item:show': (username, entity, title)->
      API.itemShow(username, entity)
      if title? then app.navigate "inventory/#{username}/#{entity}/#{title}"
      else app.navigate "inventory/#{username}/#{entity}"

    'show:item:show:from:model': (item)->
      { username } = item
      { entity } = item.attributes

      API.showItemShowFromItemModel item
      if item.pathname? then app.navigate item.pathname
      else _.error item, 'missing item.pathname'

    'show:add:layout': ->
      API.showAddLayout()
      app.navigate 'add'

    'inventory:remove:user:items': (userId)->
      # delay the action to avoid to get a ViewDestroyedError on UserLi
      # caused by the item counter trying to update
      setTimeout API.removeUserItems.bind(null, userId), 0

    'show:inventory:nearby': API.showInventoryNearby
    'show:inventory:last': API.showInventoryLast


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

    'get:item:model': API.findItemById
    'get:item:model:sync': (id)-> Items.byId id

    'inventory:main:user:length': (nonPrivate)->
      fullInventoryLength = Items.personal.length
      privateInventoryLength = mainUserPrivateInventoryLength()
      if nonPrivate then fullInventoryLength - privateInventoryLength
      else fullInventoryLength

    'inventory:user:length': (userId)->
      # Items.where({owner: userId}).length would be simpler
      # but probably less efficient?
      Items.inventoryLength[userId]

    'inventory:fetch:users:public:items': (usersIds)->
      if usersIds.length is 0
        _.warn usersIds, 'no user ids, no items fetched'
        return _.preq.resolve []

      _.preq.get usersPublicItems(usersIds)
      .then _.property('items')

    'item:main:user:instance': (entityUri)->
      return Items.personal.byEntityUri(entityUri)[0]

mainUserPrivateInventoryLength = ->
  Items.personal.where({listing: 'private'}).length
