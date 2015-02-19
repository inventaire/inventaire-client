SideNav = require '../side_nav/views/side_nav'
# ItemsLabel = require './items_label'
ItemsControl = require './items_control'
FollowedEntitiesList = require './followed_entities_list'

module.exports = class inventory extends Backbone.Marionette.LayoutView
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
    app.request 'waitForFriendsItems', @showItemsList.bind(@)

  showItemsList: ->
    {user, navigate} = @options
    if user? then user = app.request 'resolve:to:userModel', user

    if Items.length is 0
      # dont show welcome inventory screen on other users inventory
      # it would be confusing to see 'welcome in your inventory' there
      unless user?.id and not _.isMainUser(user.id)
        @showInventoryWelcome(user)
        return

    if user?
      prepareUserItemsList(user, navigate)
      if _.isMainUser(user.id) then @showFollowedEntitiesList()
      docTitle = eventName = user.get('username')
    else
      app.execute 'filter:inventory:reset'
      docTitle = _.i18n('Home')
      eventName = 'general'

    itemsList = new app.View.Items.List
      collection: Items.filtered.paginated
      columns: true
    @itemsView.show itemsList

    app.vent.trigger 'document:title:change', docTitle
    app.vent.trigger 'inventory:change', eventName

    # @beforeItems.show new ItemsLabel
    @afterItems.show new ItemsControl

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
  username = user.get 'username'
  app.execute 'filter:inventory:owner', user.id
  app.execute 'sidenav:show:user', user
  if navigate? then app.navigate "inventory/#{username}"
