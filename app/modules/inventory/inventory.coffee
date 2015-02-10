ItemShow = require './views/item_show'
Filters = require './lib/filters'
Transactions = require './lib/transactions'
InventoryLayout = require './views/inventory'
ItemCreationForm = require './views/form/item_creation'

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
    fetchItems(app)
    Filters.initialize(app)
    Transactions(Items)
    initializeInventoriesHandlers(app)

API =
  showGeneralInventory: ->
    showInventory
      ownerId: null

  showUserInventory: (user, navigate)->
    showInventory
      user: user
      navigate: navigate

  showItemCreationForm: (options)->
    form = new ItemCreationForm options
    app.layout.main.show form

  itemShow: (username, entity, label)->
    app.execute('show:loader', {title: "#{label} - #{username}"})
    app.request 'waitForFriendsItems', @showItemShow, @, username, entity, label

  showItemShow: (username, entity, label)->
    owner = app.request 'get:userId:from:username', username
    if _.isMainUser(owner)
      items = Items.personal.where({entity: entity})
    else if _.isFriend(owner)
      items = Items.friends.where({owner: owner, entity: entity})
    else
      itemsPromise = app.request 'requestPublicItem', username, entity

    _.log items, 'showItemShow items'
    if items? then @displayFoundItems(items)
    else
      if itemsPromise?
        itemsPromise
        .then @displayFoundItems
        .fail (err)-> _.logXhrErr(err)
      else app.execute 'show:404'

  displayFoundItems: (items)->
    _.log items, 'displayFoundItems items'
    if items?.length?
      switch items.length
        when 0 then app.execute 'show:404'
        when 1 then app.execute 'show:item:show:from:model', items[0]
        else
          console.warn 'multi items not implemented yet'
          app.execute 'show:item:show:from:model', items[0]
    else throw 'shouldnt be at least an empty array here?'

  showItemShowFromItemModel: (item)->
    itemShow = new ItemShow {model: item}
    app.layout.main.show itemShow

showInventory = (options)->
  unless app.user.loggedIn then return app.execute 'show:welcome'
  inventoryLayout = new InventoryLayout options
  app.layout.main.show inventoryLayout


# LOGIC
fetchItems = (app)->
  if app.user?.loggedIn
    Items.fetch({reset: true})
    .always ->
      Items.personal.fetched = true
      app.vent.trigger 'items:ready'
    .catch (err)-> _.error err, 'followed entities err'
  else
    _.log 'user not logged in. not fetching items'

  app.reqres.setHandlers
    'item:validate:creation': validateCreation
    'requestPublicItem': requestPublicItem

requestPublicItem = (username, entity)->
  _.preq.get(app.API.items.public(entity, username))
  .then (res)->
    app.users.public.add res.user
    return Items.public.add res.items
  .catch (err)-> _.error err, 'requestPublicItem err'



validateCreation = (itemData)->
  _.log itemData, 'itemData at validateCreation'
  if itemData.entity?.label? or (itemData.title? and itemData.title isnt '')
    if itemData.entity?.label?
      itemData.title = itemData.entity.label
    itemModel = Items.create itemData
    itemModel.username = app.user.get('username')
    return true
  else false

# VIEWS
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
      API.showItemShowFromItemModel(item)
      app.navigate item.pathname

    'inventory:remove:user:items': (userId)->
      userItems = Items.byOwner(userId)
      if userItems?.length > 0 then Items.remove userItems

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

    'get:item:model': (id)-> Items.personal.byId(id)

    'inventory:user:length': (userId)-> Items.inventoryLength[userId]

  require('./lib/pagination')()
