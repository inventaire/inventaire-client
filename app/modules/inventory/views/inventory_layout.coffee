InventoryNav = require './inventory_nav'
InventoryBrowser = require './inventory_browser'
showPaginatedItems = require 'modules/welcome/lib/show_paginated_items'

navs =
  user: require './inventory_user_nav'
  network: require './inventory_network_nav'
  public: require './inventory_public_nav'

module.exports = Marionette.LayoutView.extend
  id: 'inventoryLayout'
  template: require './templates/inventory'
  regions:
    inventoryNav: '#inventoryNav'
    sectionNav: '#sectionNav'
    itemsList: '#itemsList'

  initialize: ->
    { @user, @group } = @options
    @listenTo app.vent, 'inventory:select:member', @showMemberInventory.bind(@)

  childEvents:
    select: (e, type, model)->
      @showInventoryBrowser type, model
      app.navigateFromModel model

  onShow: ->
    if @user? then @showUserInventory @user
    else if @group? then @showGroupInventory @group
    else
      { section } = @options
      @showNav section
      @showSectionLastItems section

  showUserInventory: (user)->
    app.request 'resolve:to:userModel', user
    .then (userModel)=>
      section = userModel.get 'itemsCategory'
      if section is 'personal' then section = 'user'
      @showNav section, { user: userModel }
      @showInventoryBrowser 'user', userModel
      app.navigateFromModel userModel

  showGroupInventory: (group)->
    app.request 'resolve:to:groupModel', group
    .then (groupModel)=>
      section = if groupModel.mainUserIsMember() then 'network' else 'public'
      @showNav section, { group: groupModel }
      @showInventoryBrowser 'group', groupModel
      app.navigateFromModel groupModel

  showMemberInventory: (member)->
    app.request 'resolve:to:userModel', member
    .then (memberModel)=> @showInventoryBrowser 'user', memberModel

  showNav: (section, sectionNavOptions)->
    @inventoryNav.show new InventoryNav { section }
    SectionNav = navs[section]
    @sectionNav.show new SectionNav sectionNavOptions

  showInventoryBrowser: (type, model)->
    @itemsList.show new InventoryBrowser { "#{type}": model }

  showSectionLastItems: (section)->
    showPaginatedItems
      request: sectionRequest[section]
      region: @itemsList
      limit: 20
      allowMore: true

sectionRequest =
  network: 'items:getNetworkItems'
  public: 'items:getNearbyItems'
