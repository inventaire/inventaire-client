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
    { @section } = @options

  onShow: ->
    @inventoryNav.show new InventoryNav { @section }
    SectionNav = navs[@section]
    @sectionNav.show new SectionNav

    if @section is 'user'
      @itemsList.show new InventoryBrowser { user: app.user }

    # else if @section is 'network'
      # @itemsList.show new InventoryBrowser { user: app.user }
