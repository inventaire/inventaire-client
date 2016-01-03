SideNav = require '../side_nav/views/side_nav'
# FollowedEntitiesList = require './followed_entities_list'
ItemsList = require './items_list'
ItemsGrid = require './items_grid'
Controls = require './controls'
Group = require 'modules/network/views/group'
# keep in sync with _controls.scss
gridMinWidth = 750

module.exports = Marionette.LayoutView.extend
  id: 'inventory'
  template: require './templates/inventory'
  regions:
    sideNav: '#sideNav'
    header: '#header'
    itemsView: '#itemsView'
    followedView: '#followedView'
    controls: '#controls'

  initialize: ->
    @listenTo app.vent, 'inventory:layout:change', @showItemsListStep3.bind(@)

  onShow: ->
    @showSideNav()
    @showItemsListOnceData()

    if _.smallScreen()
      if @options.user? then _.scrollTop '#sideNav'
      else _.scrollTop '#itemsView'

  showSideNav: ->
    @sideNav.show new SideNav

  showItemsListOnceData: ->
    app.execute 'metadata:update:needed'
    # waitForItems to avoid having items displaying undefined values
    # waitForUserData to avoid having displaying a user profile without
    # knowing the main user
    app.request 'waitForData'
    .then @showItemsList.bind(@)
    .then app.execute.bind(app, 'metadata:update:done')
    .catch _.Error('showItemsListOnceData err')

  showItemsList: ->
    {user, group} = @options
    if user?
      app.request 'resolve:to:userModel', user
      .then @showItemsListStep2.bind(@)
      .catch (err)->
        _.error err, 'resolve:to:userModel err'
        app.execute 'show:404'

    else if group?
      app.request 'get:group:model', group
      # make sure the group is passed as second argument
      .then @showItemsListStep2.bind(@, null)
      .catch (err)->
        _.error err, 'get:group:model err'
        app.execute 'show:404'

    else @showItemsListStep2()


  showItemsListStep2: (user, group)->
    { navigate, generalInventory } = @options
    if Items.length is 0
      # dont show welcome inventory screen on other users inventory
      # it would be confusing to see 'welcome in your inventory' there
      isMainUser = if user? then app.request('user:isMainUser', user.id) else false
      if generalInventory or isMainUser
        @showInventoryWelcome(user)
        app.execute 'sidenav:show:base'
        if isMainUser then navigateToUserInventory user
        return

    if user?
      prepareUserItemsList user, navigate
      # if app.request('user:isMainUser', user.id) then @showFollowedEntitiesList()
      eventName = user.get 'username'
      user.updateMetadata()

    else if group?
      @prepareGroupItemsList group, navigate
      eventName = "group:#{group.id}"
      group.updateMetadata()
    else
      app.execute 'sidenav:show:base'
      app.execute 'filter:inventory:friends:and:main:user'
      eventName = 'general'
      updateInventoryMetadata()

    @showItemsListStep3()
    app.vent.trigger 'inventory:change', eventName

  showItemsListStep3: ->
    ItemsListView = @getItemsListView()

    itemsList = new ItemsListView
      collection: Items.filtered
    @itemsView.show itemsList

    # only triggering controls now, as it prevents controls
    # to be shown with the InventoryWelcome view
    @showControls()

  getItemsListView: ->
    switch app.request 'inventory:layout'
      when 'cascade' then ItemsList
      when 'grid' then ItemsGrid
      else throw new Error('unknow items list layout')

  showFollowedEntitiesList: ->
    followedEntities = app.request 'entities:followed:collection'
    if followedEntities.length > 0
      @followedView.show new FollowedEntitiesList {collection: followedEntities}

  showInventoryWelcome: (user)->
    inventoryWelcome = require './inventory_welcome'
    showLastPublicItems = require 'modules/welcome/lib/show_last_public_items'

    @header.show new inventoryWelcome
    showLastPublicItems @itemsView
    .catch _.Error('showLastPublicItems err')

    if user? then app.execute 'sidenav:show:user', user

  showControls: ->
    unless _.smallScreen gridMinWidth
      @controls.show new Controls

  prepareGroupItemsList: (group, navigate)->
    app.execute 'filter:inventory:group', group
    app.execute 'sidenav:show:group', group
    unless _.smallScreen()
      @header.show new Group
        model: group
        highlighted: true
    # else shown by side_nav::showGroup

    pathname = group.get 'pathname'
    if navigate then app.navigate pathname
    # correcting possibly custom or outdated group name
    else app.navigateReplace pathname

prepareUserItemsList = (user, navigate)->
  unless app.request 'user:itemsFetched', user
    fetchUserPublicItems user

  username = user.get 'username'
  app.execute 'filter:inventory:owner', user.id
  app.execute 'sidenav:show:user', user
  if navigate then navigateToUserInventory user

navigateToUserInventory = (user)-> app.navigate user.get('pathname')


fetchUserPublicItems = (user)->
  app.request 'inventory:fetch:users:public:items', user.id
  .then _.Log('public user public items')
  .then Items.public.add
  .catch _.Error('fetchUserPublicItems')

  # remove items on inventory change
  removeUserItems = -> app.execute('inventory:remove:user:items', user.id)
  cb = -> app.vent.once('inventory:change', removeUserItems)
  setTimeout cb, 500

updateInventoryMetadata = ->
  app.execute 'metadata:update',
    title: _.I18n 'title_browse_layout'
    url: '/inventory'
    # keep the general description and image
