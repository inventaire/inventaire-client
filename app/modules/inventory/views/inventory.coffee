SideNav = require '../side_nav/views/side_nav'
FollowedEntitiesList = require './followed_entities_list'

module.exports = Backbone.Marionette.LayoutView.extend
  id: 'inventory'
  template: require './templates/inventory'
  regions:
    sideNav: '#sideNav'
    beforeItems: '#beforeItems'
    itemsView: '#itemsView'
    afterItems: '#afterItems'
    followedView: '#followedView'

  onShow: ->
    @sideNav.show new SideNav
    # waitForData to avoid having items displaying undefined values
    @showItemsListOnceData()


  showItemsListOnceData: ->
    app.request 'waitForItems', @showItemsList.bind(@)

  showItemsList: ->
    {user} = @options
    unless user? then return @showItemsListStep2()

    app.request 'resolve:to:userModel', user
    .catch -> app.execute 'show:404'
    .then @showItemsListStep2.bind(@)

  showItemsListStep2: (user)->
    {navigate} = @options
    if Items.length is 0
      # dont show welcome inventory screen on other users inventory
      # it would be confusing to see 'welcome in your inventory' there
      unless user?.id and not app.request 'user:isMainUser', user.id
        @showInventoryWelcome(user)
        return

    if user?
      prepareUserItemsList(user, navigate)
      if app.request('user:isMainUser', user.id) then @showFollowedEntitiesList()
      docTitle = eventName = user.get('username')
    else
      app.execute 'filter:inventory:reset'
      docTitle = _.i18n('Home')
      eventName = 'general'

    itemsList = new app.View.Items.List
      collection: Items.filtered
      columns: true
    @itemsView.show itemsList

    app.vent.trigger 'document:title:change', docTitle
    app.vent.trigger 'inventory:change', eventName

  showFollowedEntitiesList: ->
    followedEntities = app.request 'entities:followed:collection'
    if followedEntities.length > 0
      @followedView.show new FollowedEntitiesList {collection: followedEntities}

  showInventoryWelcome: (user)->
    inventoryWelcome = require('./inventory_welcome')
    view = new inventoryWelcome
    @itemsView.show view
    if user? then app.execute 'sidenav:show:user', user

prepareUserItemsList = (user, navigate)->
  if app.request 'user:isPublicUser', user.id
    fetchPublicUserItems(user)

  username = user.get 'username'
  app.execute 'filter:inventory:owner', user.id
  app.execute 'sidenav:show:user', user
  if navigate? then app.navigate "inventory/#{username}"

fetchPublicUserItems = (user)->
  # fetch items
  app.request 'inventory:fetch:user:public:items', user.id
  .then _.Log('items')
  .then (items)-> Items.public.add items
  .catch _.Error('fetchPublicUserItems')

  # remove items on inventory change
  removeUserItems = -> app.execute('inventory:remove:user:items', user.id)
  cb = -> app.vent.once('inventory:change', removeUserItems)
  setTimeout cb, 500
