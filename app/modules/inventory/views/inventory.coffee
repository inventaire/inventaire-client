SideNav = require '../side_nav/views/side_nav'
ItemsList = require './items_list'
ItemsGrid = require './items_grid'
# Controls = require './controls'
Group = require 'modules/network/views/group'
showPaginatedItems = require 'modules/welcome/lib/show_paginated_items'
PositionWelcome = require 'modules/map/views/position_welcome'
{ CheckViewState, catchDestroyedView } = require 'lib/view_state'
itemsPerPage = require '../lib/items_per_pages'

# keep in sync with _controls.scss
gridMinWidth = 750

module.exports = Marionette.LayoutView.extend
  id: 'inventory'
  template: require './templates/inventory'
  regions:
    sideNav: '#sideNav'
    header: '#header'
    itemsView: '#itemsView'
    # controls: '#controls'

  initialize: ->
    @listenTo app.vent, 'inventory:layout:change', @showItemsListStep3.bind(@)

  onShow: ->
    # It's faster to wait for all the network data to arrive and then render
    # the side nav, than rendering the side nav and adding users and groups
    # one by one
    app.request 'waitForNetwork'
    .then @showSideNav.bind(@)
    .then @showItemsListOnceData.bind(@)

    # Commenting-out scrolling to <main>'s top
    # as keeping the icon_nav visible helps keeping landmarks
    # see also app/modules/general/views/icon_nav.coffee showLayout
    # if _.smallScreen()
    #   if @options.user? then _.scrollTop '#sideNav'
    #   else _.scrollTop '#itemsView'

  showSideNav: ->
    @sideNav.show new SideNav

  showItemsListOnceData: ->
    # waitForItems to avoid having items displaying undefined values
    # waitForUserData to avoid having displaying a user profile without
    # knowing the main user

    waitForData = @options.waitForData or _.preq.resolved

    waitForData
    .then CheckViewState(@, 'inventory')
    .then @showItemsList.bind(@)
    .catch catchDestroyedView
    .catch _.Error('showItemsListOnceData err')

  showItemsList: ->
    { user, group, nearby, last } = @options

    if nearby
      if app.user.hasPosition() then @showItemsNearby()
      else @showPositionWelcome()
      app.vent.trigger 'sidenav:show:base', 'nearby'
      app.navigate 'inventory/nearby',
        metadata: { title: _.i18n('title_map_layout') }
      return

    if last
      @showLastPublicItems()
      app.vent.trigger 'sidenav:show:base', 'last'
      app.navigate 'inventory/last',
        metadata: { title: _.i18n('title_last_items') }
      return

    if user?
      app.request 'resolve:to:userModel', user
      .then @showItemsListStep2.bind(@)
      .catch (err)->
        _.error err, 'resolve:to:userModel err'
        app.execute 'show:error:missing'

    else if group?
      # get:group:model takes care of fetching the group users
      # and items public data
      app.request 'get:group:model', group
      .tap (group)->
        group.beforeShow()
        group.boostHighlightScore()
      # make sure the group is passed as second argument
      .then @showItemsListStep2.bind(@, null)
      .catch (err)->
        _.error err, 'get:group:model err'
        app.execute 'show:error:missing'

    else @showItemsListStep2()

  showItemsListStep2: (user, group)->
    model = null
    fallback = null

    if user?
      prepareUserItemsList user
      eventName = user.get 'username'
      app.navigateFromModel user
      model = user
      request = 'items:getUserItems'
      if app.request 'user:isMainUser', user.id
        fallback = @showInventoryWelcome.bind @, user

    else if group?
      prepareGroupItemsList.call @, group
      eventName = "group:#{group.id}"
      app.navigateFromModel group
      request = 'items:getGroupItems'
      model = group

    else
      app.vent.trigger 'sidenav:show:base'
      eventName = 'general'
      app.navigate 'inventory', { metadata: inventoryMetadata() }
      request = 'items:getNetworkItems'
      fallback = @showInventoryWelcome.bind @

    @showItemsListStep3 request, model, fallback
    app.vent.trigger 'inventory:change', eventName

  showItemsListStep3: (request, model, fallback)->
    showPaginatedItems
      request: request
      model: model
      region: @itemsView
      limit: itemsPerPage 5
      allowMore: true
      ItemsListView: @getItemsListView()
      fallback: fallback
    .catch _.Error('showLastPublicItems err')

    # Commented-out as filter features aren't available
    # in the current implementation
    # # only triggering controls now, as it prevents controls
    # # to be shown with the InventoryWelcome view
    # @showControls()

  getItemsListView: ->
    switch app.request 'inventory:layout'
      when 'cascade' then ItemsList
      when 'grid' then ItemsGrid
      else throw new Error('unknow items list layout')

  showInventoryWelcome: (user)->
    inventoryWelcome = require './inventory_welcome'
    @header.show new inventoryWelcome
    @showLastPublicItems()
    if user?
      app.vent.trigger 'sidenav:show:user', user
    else
      app.vent.trigger 'sidenav:show:base'

  showLastPublicItems: (params)->
    showPaginatedItems
      request: 'items:getLastPublic'
      region: @itemsView
      limit: itemsPerPage 5
      allowMore: true
      showDistance: true
    .catch _.Error('showLastPublicItems err')

  # showControls: ->
  #   unless _.smallScreen gridMinWidth
  #     @controls.show new Controls

  showItemsNearby: ->
    app.request 'items:getNearbyItems'
    .then (items)=>
      @itemsView.show new ItemsList
        collection: items
        showDistance: true
    .catch _.Error('showItemsNearby')

  showPositionWelcome: ->
    @itemsView.show new PositionWelcome

prepareUserItemsList = (user)-> app.vent.trigger 'sidenav:show:user', user

prepareGroupItemsList = (group)->
  app.vent.trigger 'sidenav:show:group', group
  unless _.smallScreen()
    @header.show new Group
      model: group
      highlighted: true
  # else shown by side_nav::showGroup

inventoryMetadata = ->
  title: _.I18n 'title_browse_layout'
  url: '/inventory'
  # keep the general description and image
