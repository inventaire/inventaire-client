InventoryNav = require './inventory_nav'
InventoryBrowser = require './inventory_browser'
UserProfile = require './user_profile'
GroupProfile = require './group_profile'
ShelfView = require '../../shelves/views/shelf'
ShelvesLayout = require '../../shelves/views/shelves_layout'
{ getById } = require '../../shelves/lib/shelf'
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
    shelvesList: '#shelvesList'
    shelfInfo: '#shelfInfo'
    itemsList: '#itemsList'

  initialize: ->
    { @user, @group, @shelf, @standalone } = @options
    @listenTo app.vent, 'inventory:select', @showSelectedInventory.bind(@)

  onShow: ->
    if @user?
      @startFromUser @user, @shelf
      @showUserShelves @user

    else if @group?
      @startFromGroup @group
    else
      { section, filter } = @options
      @showInventoryNav section
      @showSectionNav section
      unless filter? then @showSectionLastItems section

  startFromUser: (user, shelf)->
    app.request 'resolve:to:userModel', user
    .then (userModel)=>
      if shelf
        @showShelf shelf
      else
        @showUserInventory userModel
        app.navigateFromModel userModel
      @showUserProfile userModel
      section = userModel.get 'itemsCategory'
      if section is 'personal' then section = 'user'
      @showInventoryNav section
      @showSectionNav section, 'user', userModel
      # Do not scroll when showing the main user's inventory
      # to keep the other nav elements visible
      if section isnt 'user' then scrollToSection @userProfile
    .catch app.Execute('show:error')

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
    .catch app.Execute('show:error')

  showShelf: (shelf)->
    itemsDataPromise = getItemsData('shelf', shelf.id)
    isMainUser = app.user.id is shelf.get('owner')
    @shelfInfo.show new ShelfView { model: shelf }
    @itemsList.show new InventoryBrowser { itemsDataPromise, isMainUser }
    scrollToSection @shelfInfo

  showUserShelves: (userIdOrUsername)->
    app.request 'resolve:to:userModel', userIdOrUsername
    .then (userModel)=>
      username = userModel.get('username')
      if wrapperExists() then return $('.shelvesWrapper').show()
      @shelvesList.show new ShelvesLayout { username }
    .catch app.Execute('show:error')

  showUserInventory: (userModel)->
    if userModel is app.user and userModel.get('itemsCount') is 0
      @showInventoryWelcome()
    else
      @showInventoryBrowser 'user', userModel

  showInventoryWelcome: ->
    InventoryWelcome = require './inventory_welcome'
    @itemsList.show new InventoryWelcome

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
    unless app.user.loggedIn then return
    section = if not @standalone or section is 'user' then section
    @inventoryNav.show new InventoryNav { section }

  showSectionNav: (section, type, model)->
    if @standalone or not app.user.loggedIn then return
    SectionNav = navs[section]
    unless SectionNav? then return
    options = if type? and model? then { "#{type}": model } else {}
    options.filter = @options.filter
    @sectionNav.show new SectionNav options

  showInventoryBrowser: (type, model)->
    modelId = model.get('_id')
    itemsDataPromise = getItemsData(type, modelId)
    isMainUser = model?.isMainUser
    @itemsList.show new InventoryBrowser { itemsDataPromise, isMainUser }

  showSectionLastItems: (section)->
    if section is 'public' and not app.user.get('position') then return

    showPaginatedItems
      request: sectionRequest[section]
      region: @itemsList
      limit: 20
      allowMore: true
      showDistance: section is 'public'

  showSelectedInventory: (type, model)->
    if type is 'user' or type is 'group'
      if type is 'user'
        @showUserInventory model
        @showUserProfile model
        @groupProfile.empty()
        @showUserShelves model
        scrollToSection @userProfile
      else
        @showGroupProfile model
        @userProfile.empty()
        @showGroupInventory model
        scrollToSection @groupProfile
    else if type is 'member'
      @showUserProfile model
      @showMemberInventory model
      scrollToSection @userProfile
    else if type is 'shelf'
      user = model.get 'owner'
      @showUserShelves user
      @showShelf model

    app.navigateFromModel model

getItemsData = (type, modelId)->
  params = { "#{type}": modelId }
  _.preq.get app.API.items.inventoryView(params)

sectionRequest =
  network: 'items:getNetworkItems'
  public: 'items:getNearbyItems'

scrollToSection = (region)->
  screen_.scrollTop { $el: region.$el, marginTop: 10, delay: 100 }

wrapperExists = ->
  $('.shelvesWrapper').length > 0
