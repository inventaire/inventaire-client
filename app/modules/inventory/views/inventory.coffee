SideNav = require '../side_nav/views/side_nav'
# FollowedEntitiesList = require './followed_entities_list'
ItemsGrid = require './items_grid'
Controls = require './controls'
# keep in sync with _controls.scss
gridMinWidth = 750

module.exports = Marionette.LayoutView.extend
  id: 'inventory'
  template: require './templates/inventory'
  regions:
    sideNav: '#sideNav'
    welcomeView: '#welcomeView'
    itemsView: '#itemsView'
    followedView: '#followedView'
    controls: '#controls'

  initialize: ->
    @listenTo app.vent, 'inventory:layout:change', @showItemsListStep3.bind(@)

  events:
    'inview #itemsView': 'toggleControls'

  toggleControls: ->
    if $('#itemsView').visible(true) then $('#controls').show()
    else $('#controls').hide()

  onShow: ->
    @showSideNav()
    @showItemsListOnceData()
    unless _.smallScreen(gridMinWidth)
      @controls.show new Controls

    if _.smallScreen()
      if @options.user? then _.scrollTop '#sideNav'
      else _.scrollTop '#itemsView'

  showSideNav: ->
    @sideNav.show new SideNav

  showItemsListOnceData: ->
    # waitForItems to avoid having items displaying undefined values
    app.request('waitForItems')
    .then @showItemsList.bind(@)
    .catch _.Error('showItemsListOnceData err')

  showItemsList: ->
    {user, group} = @options
    if user?
      app.request 'resolve:to:userModel', user
      .catch (err)->
        _.error err, 'resolve:to:userModel err'
        app.execute 'show:404'
      .then @showItemsListStep2.bind(@)

    else if group?
      app.request 'get:group:model', group
      .catch (err)->
        _.error err, 'get:group:model err'
        app.execute 'show:404'
      .then @showItemsListStep2.bind(@, null)

    else @showItemsListStep2()


  showItemsListStep2: (user, group)->
    { navigate, generalInventory } = @options
    if Items.length is 0
      # dont show welcome inventory screen on other users inventory
      # it would be confusing to see 'welcome in your inventory' there
      if generalInventory or app.request 'user:isMainUser', user.id
        @showInventoryWelcome(user)
        app.execute 'sidenav:show:base'
        return

    if user?
      prepareUserItemsList user, navigate
      # if app.request('user:isMainUser', user.id) then @showFollowedEntitiesList()
      docTitle = eventName = user.get('username')
    else if group?
      prepareGroupItemsList group, navigate
      docTitle = group.get 'name'
      eventName = "group:#{group.id}"
    else
      app.execute 'sidenav:show:base'
      app.execute 'filter:inventory:friends'
      docTitle = _.I18n 'title_browse_layout'
      eventName = 'general'

    @showItemsListStep3()
    app.vent.trigger 'document:title:change', docTitle
    app.vent.trigger 'inventory:change', eventName

  showItemsListStep3: ->
    ItemsListView = @getItemsListView()

    itemsList = new ItemsListView
      collection: Items.filtered
    @itemsView.show itemsList

  getItemsListView: ->
    switch app.request 'inventory:layout'
      when 'cascade' then app.View.Items.List
      when 'grid' then ItemsGrid
      else throw new Error('unknow items list layout')

  showFollowedEntitiesList: ->
    followedEntities = app.request 'entities:followed:collection'
    if followedEntities.length > 0
      @followedView.show new FollowedEntitiesList {collection: followedEntities}

  showInventoryWelcome: (user)->
    inventoryWelcome = require './inventory_welcome'
    showLastPublicItems = require 'modules/welcome/lib/show_last_public_items'

    @welcomeView.show new inventoryWelcome
    showLastPublicItems @itemsView
    .catch _.Error('showLastPublicItems err')

    if user? then app.execute 'sidenav:show:user', user

prepareUserItemsList = (user, navigate)->
  unless app.request 'user:itemsFetched', user
    fetchUserPublicItems user

  username = user.get 'username'
  app.execute 'filter:inventory:owner', user.id
  app.execute 'sidenav:show:user', user
  if navigate then app.navigate user.get('pathname')

prepareGroupItemsList = (group, navigate)->
  app.execute 'filter:inventory:group', group
  app.execute 'sidenav:show:group', group
  if navigate then app.navigate group.get('pathname')

fetchUserPublicItems = (user)->
  app.request 'inventory:fetch:user:public:items', user.id
  .then _.Log('public user public items')
  .then Items.public.add
  .catch _.Error('fetchUserPublicItems')

  # remove items on inventory change
  removeUserItems = -> app.execute('inventory:remove:user:items', user.id)
  cb = -> app.vent.once('inventory:change', removeUserItems)
  setTimeout cb, 500
