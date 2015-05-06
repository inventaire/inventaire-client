ItemShow = require './views/item_show'
Filters = require './lib/filters'
Transactions = require './lib/transactions'
InventoryLayout = require './views/inventory'
ItemCreationForm = require './views/form/item_creation'
initLayout = require './lib/layout'

module.exports =
  define: (Inventory, app, Backbone, Marionette, $, _) ->
    InventoryRouter = Marionette.AppRouter.extend
      appRoutes:
        'inventory(/)': 'showGeneralInventory'
        'inventory/:user(/)': 'showUserInventory'
        'inventory/:user/:entity(/:title)(/)': 'itemShow'

    app.addInitializer ->
      new InventoryRouter
        controller: API


  initialize: ->
    window.Items = Items = require('./items_collections')(app, _)
    app.request('waitForUserData').then fetchItems.bind(null, app)
    Filters.initialize(app)
    Transactions(Items)
    initializeInventoriesHandlers(app)
    initLayout(app)

API =
  showGeneralInventory: ->
    if app.request 'require:loggedIn', 'inventory'
      showInventory
        ownerId: null

  showUserInventory: (user, navigate)->
    if app.request 'require:loggedIn', "inventory/#{user}"
      showInventory
        user: user
        navigate: navigate

  showItemCreationForm: (options)->
    form = new ItemCreationForm options
    app.layout.main.show form

  itemShow: (username, entity, label)->
    route = "inventory/#{username}/#{entity}"
    if app.request 'require:loggedIn', route
      app.execute('show:loader', {title: "#{label} - #{username}"})
      app.request('waitForItems')
      .then @showItemShow.bind(@, username, entity, label)

  showItemShow: (username, entity, label)->
    _.preq.start()
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
      return app.request 'requestPublicItem', username, entity
    else
      return Items.where({owner: owner, entity: entity})

  findItemById: (itemId)->
    app.request('waitForFriendsItems')
    .then Items.byId.bind(Items, itemId)
    .then (item)->
      if item? then item
      else
        # if it isnt in friends id, it should be a public item
        _.preq.get app.API.items.publicById(itemId)
        .then _.Log('found item?')
        .then Items.public.add
        .catch _.Error('findItemById err')

  displayFoundItems: (items)->
    _.log items, 'displayFoundItems items'
    unless items?.length?
      throw 'shouldnt be at least an empty array here?'

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
    userItems = Items.byOwner(userId)
    if userItems?.length > 0 then Items.remove userItems

showInventory = (options)->
  inventoryLayout = new InventoryLayout options
  app.layout.main.show inventoryLayout


# LOGIC
fetchItems = (app)->
  if app.user?.loggedIn
    Items.fetch({reset: true})
    .always triggerItemsReady
  else
    _.log 'user isnt logged in. not fetching items'
    triggerItemsReady()

  app.reqres.setHandlers
    'item:validate:creation': validateCreation
    'requestPublicItem': requestPublicItem

triggerItemsReady = ->
  Items.personal.fetched = true
  app.vent.trigger 'items:ready'

requestPublicItem = (username, entity)->
  _.preq.get(app.API.items.publicByUsernameAndEntity(username, entity))
  .then (res)->
    app.users.public.add res.user
    return Items.public.add res.items
  .catch (err)-> _.error err, 'requestPublicItem err'


validateCreation = (itemData)->
  _.log itemData, 'itemData at validateCreation'
  unless itemData.entity?.label? or (itemData.title? and itemData.title isnt '')
    return false

  if itemData.entity?.label?
    itemData.title = itemData.entity.label
  itemModel = Items.create itemData
  itemModel.username = app.user.get('username')
  return true

initializeInventoriesHandlers = (app)->
  app.commands.setHandlers
    'show:inventory:general': ->
      API.showGeneralInventory()
      app.navigate 'inventory'

    'show:inventory:user': (user)->
      API.showUserInventory(user, true)

    'show:item:creation:form': (params)->
      API.showItemCreationForm(params)
      if params.entity?
        pathname = params.entity.get 'pathname'
        app.navigate "#{pathname}/add"
      else throw new Error 'missing entity'

    'show:item:show': (username, entity, title)->
      API.itemShow(username, entity)
      if title? then app.navigate "inventory/#{username}/#{entity}/#{title}"
      else app.navigate "inventory/#{username}/#{entity}"

    'show:item:show:from:model': (item)->
      { username } = item
      { entity } = item.attributes

      route = "inventory/#{username}/#{entity}"
      if app.request 'require:loggedIn', route
        API.showItemShowFromItemModel(item)
        if item.pathname? then app.navigate item.pathname
        else _.error item, 'missing item.pathname'

    'inventory:remove:user:items': (userId)->
      # delay the action to avoid to get a ViewDestroyedError on UserLi
      # caused by the item counter trying to update
      setTimeout API.removeUserItems.bind(null, userId), 200


  app.reqres.setHandlers
    'item:update': (options)->
      # expects: item, attribute, value
      # optional: selector
      {item, attribute, value, selector} = options
      types = ['object', 'string', 'string|array', 'string|undefined']
      _.types [item, attribute, value, selector], types

      item.set(attribute, value)
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
    'inventory:user:length': (userId)-> Items.inventoryLength[userId]

    'inventory:fetch:user:public:items': (userId)->
      unless _.isUserId(userId)
        throw new Error "expected a userId, got #{userId}"
      _.preq.get app.API.items.userPublicItems(userId)
