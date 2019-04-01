InventoryCommonNav = require 'modules/inventory/views/inventory_common_nav'

module.exports = InventoryCommonNav.extend
  id: 'inventoryNetworkNav'
  template: require './templates/inventory_network_nav'

  onShow: ->
    app.request 'fetch:friends'
    .then (collection)=> @showList @usersList, collection

    app.request 'wait:for', 'groups'
    .then => @showList @groupsList, app.groups

    @initProfile()
