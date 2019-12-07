InventoryNav = require './inventory_nav'
InventoryBrowser = require './inventory_browser'
UserProfile = require 'modules/inventory/views/user_profile'
GroupProfile = require 'modules/network/views/group_profile'
showPaginatedItems = require 'modules/welcome/lib/show_paginated_items'
screen_ = require 'lib/screen'

navs =
  network: require './inventory_network_nav'
  public: require './inventory_public_nav'

module.exports = Marionette.LayoutView.extend
  id: 'inventoryLayout'
  template: require './templates/inventory_layout'
  regions:
    inventoryNav: '#inventoryNav'
    sectionNav: '#sectionNav'
    groupProfile: '#groupProfile'
    userProfile: '#userProfile'
    itemsList: '#itemsList'

  initialize: ->
    { @user, @group } = @options
    @listenTo app.vent, 'inventory:select', @showSelectedInventory.bind(@)

  onShow: ->
    if @user?
      @startFromUser @user
    else if @group?
      @startFromGroup @group
    else
      { section } = @options
      @showInventoryNav section
      @showSectionNav section
      @showSectionLastItems section

  startFromUser: (user)->
    app.request 'resolve:to:userModel', user
    .then (userModel)=>
      @showUserInventory userModel
      @showUserProfile userModel
      section = userModel.get 'itemsCategory'
      if section is 'personal' then section = 'user'
      @showInventoryNav section
      @showSectionNav section, 'user', userModel
      app.navigateFromModel userModel
      # Do not scroll when showing the main user inventory
      # to keep the other nav elements visible
      if section isnt 'user' then scrollToSection @userProfile

  startFromGroup: (group)->
    app.request 'resolve:to:groupModel', group
    .then (groupModel)=> @showGroupInventory groupModel
    .then (groupModel)=>
      section = if groupModel.mainUserIsMember() then 'network' else 'public'
      @showInventoryNav section
      @showSectionNav section, 'group', groupModel
      @showGroupProfile groupModel
      app.navigateFromModel groupModel
      scrollToSection @groupProfile

  showUserInventory: (userModel)->
    @showInventoryBrowser 'user', userModel

  showGroupInventory: (groupModel)->
    groupModel.beforeShow()
    .then =>
      @showInventoryBrowser 'group', groupModel
      return groupModel

  showMemberInventory: (member)->
    app.request 'resolve:to:userModel', member
    .then (memberModel)=>
      @showUserProfile memberModel
      @showInventoryBrowser 'user', memberModel
      scrollToSection @userProfile

  showGroupProfile: (groupModel)-> @groupProfile.show new GroupProfile { model: groupModel }

  showUserProfile: (userModel)-> @userProfile.show new UserProfile { model: userModel }

  showInventoryNav: (section)->
    @inventoryNav.show new InventoryNav { section }

  showSectionNav: (section, type, model)->
    SectionNav = navs[section]
    unless SectionNav? then return
    options = if type? and model? then { "#{type}": model } else {}
    @sectionNav.show new SectionNav options

  showInventoryBrowser: (type, model)->
    @itemsList.show new InventoryBrowser { "#{type}": model }

  showSectionLastItems: (section)->
    showPaginatedItems
      request: sectionRequest[section]
      region: @itemsList
      limit: 20
      allowMore: true

  showSelectedInventory: (type, model)->
    if type is 'user' or type is 'group'
      if type is 'user'
        @showUserInventory model
        @showUserProfile model
        @groupProfile.empty()
        scrollToSection @userProfile
      else
        @showGroupProfile model
        @userProfile.empty()
        @showGroupInventory model
        scrollToSection @groupProfile
      app.navigateFromModel model
    else if type is 'member'
      @showUserProfile model
      @showMemberInventory model
      scrollToSection @userProfile

sectionRequest =
  network: 'items:getNetworkItems'
  public: 'items:getNearbyItems'

scrollToSection = (region)->
  screen_.scrollTop { $el: region.$el, marginTop: 10, delay: 100 }
