InventoryNav = require './inventory_nav'
InventoryUserNav =
InventoryNetworkNav = require './inventory_network_nav'
InventoryBrowser = require './inventory_browser'

navs =
  user: require './inventory_user_nav'
  network: require './inventory_network_nav'
  public: require './inventory_public_nav'

module.exports = Marionette.LayoutView.extend
  id: 'inventory'
  template: require './templates/inventory'
  regions:
    inventoryNav: '#inventoryNav'
    sectionNav: '#sectionNav'
    itemsList: '#itemsList'

  initialize: ->
    { @user, @group } = @options

    @listenTo app.vent, 'inventory:show:user', @showUserInventory.bind(@)
    @listenTo app.vent, 'inventory:show:group', @showGroupInventory.bind(@)

  onShow: ->
    if @user? then @showUserInventory @user
    else if @group? then @showGroupInventory @group
    else @showNav @options.section

  showUserInventory: (user)->
    app.request 'resolve:to:userModel', user
    .then (userModel)=>
      section = userModel.get 'itemsCategory'
      if section is 'personal' then section = 'user'
      @showNav section
      @itemsList.show new InventoryBrowser { user: userModel }
      app.navigateFromModel userModel

  showGroupInventory: (group)->
    app.request 'resolve:to:groupModel', group
    .then (groupModel)=>
      # TODO: adapt to case when the main user isn't in the shown group
      @showNav 'network'
      @itemsList.show new InventoryBrowser { group: groupModel }
      app.navigateFromModel groupModel

  showNav: (section)->
    @inventoryNav.show new InventoryNav { section }
    SectionNav = navs[section]
    @sectionNav.show new SectionNav
