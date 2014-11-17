ItemShow = require './views/item_show'
Filters = require './lib/filters'

module.exports =
  define: (Inventory, app, Backbone, Marionette, $, _) ->
    InventoryRouter = Marionette.AppRouter.extend
      appRoutes:
        'inventory(/)': 'goToPersonalInventory'
        'inventory/personal(/)': 'showPersonalInventory'
        'inventory/friends(/)': 'showFriendsInventory'
        'inventory/public(/)': 'showPublicInventory'
        # 'inventory/:user(/)': 'showUserInventory'
        'inventory/:user/:suffix(/:title)(/)': 'itemShow'

    app.addInitializer ->
      new InventoryRouter
        controller: API


  initialize: ->
    # LOGIC
    window.Items =
      personal: new app.Collection.Items
      friends: new app.Collection.Items
      public: new app.Collection.Items

    fetchItems(app)
    Filters.initialize(app)

    # VIEWS
    initializeInventoriesHandlers(app)

API =
  goToPersonalInventory: ->
    @showPersonalInventory()
    app.navigateReplace 'inventory/personal'

  showPersonalInventory: ->
    showInventory _.i18n('Personal')
    showItemList(Items.personal.filtered)
    app.execute 'filter:visibility:reset'
    app.vent.trigger 'inventory:change', 'personal'

  showFriendsInventory: ->
    Items.friends.filtered.resetFilters()
    showInventory _.i18n('Friends')
    showItemList(Items.friends.filtered)
    app.vent.trigger 'inventory:change', 'friends'

  showPublicInventory: ->
    showInventory _.i18n('Public')
    app.execute('show:loader', {region: app.inventory.itemsView})
    _.preq.get(app.API.items.public())
    .then (res)->
      _.log res, 'Items.public res'
      # not testing if res has items or users
      # letting the inventory empty view do the job
      app.users.public.add res.users
      Items.public.add res.items
      showItemList(Items.public)
      app.vent.trigger 'inventory:change', 'public'
    .fail (err)->
      if err.status is 404
        showItemList()

  showItemCreationForm: (options)->
    form = new app.View.Items.Creation options
    app.layout.main.show form

  # should be reimplemented taking example on ItemShow switch
  # showUserInventory: (user)->
  # app.request 'waitForData', @filterForUser, @

  # filterForUser: ->
  #   owner = app.request 'get:userId:from:username', user
  #   if owner?
  #     app.execute 'filter:inventory:owner', Items.friends.filtered, owner
  #   else
  #     _.log [user, owner], 'user not found: you should do some ajax wizzardry to get him'

  itemShow: (username, suffix, label)->
    app.execute('show:loader', {title: "#{label} - #{username}"})
    app.request 'waitForData', @showItemShow, @, username, suffix, label

  showItemShow: (username, suffix, label)->
    owner = app.request 'get:userId:from:username', username
    if _.isUser(owner)
      items = Items.personal.where({suffix: suffix})
    else if _.isFriend(owner)
      items = Items.friends.where({owner: owner, suffix: suffix})
    else
      itemsPromise = app.request 'requestPublicItem', username, suffix

    if items? then @displayFoundItems(items)
    else
      if itemsPromise?
        itemsPromise
        .then @displayFoundItems
        .fail (err)-> _.logXhrErr(err)
      else app.execute 'show:404'

  displayFoundItems: (items)->
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

showInventory = (docTitle)->
  # regions shouldnt be undefined, which can't be tested by "app.invenshowItemShowtory?._isShown"
  # so here I just test one of Inventory regions
  unless app.inventory?.itemsView?
    app.inventory = new app.Layout.Inventory
    app.layout.main.Show app.inventory, docTitle
  else app.docTitle(docTitle)

showItemList = (collection)->
  # waitForData to avoid having items displaying undefined values
  app.request 'waitForData', ->
    itemsList = app.inventory.itemsList = new app.View.ItemsList {collection: collection}
    app.inventory.itemsView.show itemsList


# LOGIC
fetchItems = (app)->
  Items.personal.fetch({reset: true})
  .always ->
    Items.personal.fetched = true
    app.vent.trigger 'items:ready'

  app.reqres.setHandlers
    'item:validate:creation': validateCreation
    'requestPublicItem': requestPublicItem

requestPublicItem = (username, suffix)->
  _.preq.get(app.API.items.public(suffix, username))
  .then (res)->
    app.users.public.add res.user
    return Items.public.add res.items


validateCreation = (itemData)->
  _.log itemData, 'itemData at validateCreation'
  if itemData.entity?.label? or (itemData.title? and itemData.title isnt '')
    if itemData.entity?.label?
      itemData.title = itemData.entity.label
    itemModel = Items.personal.create itemData
    itemModel.username = app.user.get('username')
    return true
  else false

# VIEWS
initializeInventoriesHandlers = (app)->
  app.commands.setHandlers
    'show:inventory:personal': ->
      API.showPersonalInventory()
      app.navigate 'inventory/personal'

    'show:inventory:friends': ->
      API.showFriendsInventory()
      app.navigate 'inventory/friends'

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
      app.navigate item.pathname

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