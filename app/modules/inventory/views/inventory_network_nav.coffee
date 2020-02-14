InventoryCommonNav = require 'modules/inventory/views/inventory_common_nav'

module.exports = InventoryCommonNav.extend
  id: 'inventoryNetworkNav'
  template: require './templates/inventory_network_nav'

  behaviors:
    PreventDefault: {}

  ui:
    showUsersMenu: '.showUsersMenu'
    userMenu: '.userMenu'
    groupMenu: '.groupMenu'

  onShow: ->
    app.request 'fetch:friends'
    .then (collection)=> @showList @usersList, collection

    app.request 'wait:for', 'groups'
    .then => @showList @groupsList, app.groups

  events:
    'click .showUsersMenu': 'showUsersMenu'
    'click .showGroupsMenu': 'showGroupsMenu'
    'click .inviteByEmail': _.clickCommand 'show:invite:friend:by:email'
    'click .searchUser': _.clickCommand 'show:user:search'
    'click .showInventoryPublic': _.clickCommand 'show:inventory:public'

  showUsersMenu: ->
    @ui.showUsersMenu.hide()
    @ui.userMenu.removeClass 'force-hidden'

  showGroupsMenu: (e)->
    unless _.isOpenedOutside e then app.execute 'show:groups:menu'
