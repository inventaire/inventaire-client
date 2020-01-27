InventoryCommonNav = require 'modules/inventory/views/inventory_common_nav'

module.exports = InventoryCommonNav.extend
  id: 'inventoryNetworkNav'
  template: require './templates/inventory_network_nav'

  behaviors:
    PreventDefault: {}

  onShow: ->
    app.request 'fetch:friends'
    .then (collection)=> @showList @usersList, collection

    app.request 'wait:for', 'groups'
    .then => @showList @groupsList, app.groups

  events:
    'click .showUsersMenu': 'showUsersMenu'
    'click .showGroupsMenu': 'showGroupsMenu'

  showUsersMenu: (e)->
    unless _.isOpenedOutside e then app.execute 'show:users:menu'

  showGroupsMenu: (e)->
    unless _.isOpenedOutside e then app.execute 'show:groups:menu'
