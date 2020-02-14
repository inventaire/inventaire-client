InventoryCommonNav = require 'modules/inventory/views/inventory_common_nav'

module.exports = InventoryCommonNav.extend
  id: 'inventoryNetworkNav'
  template: require './templates/inventory_network_nav'

  behaviors:
    PreventDefault: {}

  ui:
    showUsersMenu: '.showUsersMenu'
    showGroupsMenu: '.showGroupsMenu'
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
    'click .searchUsers': _.clickCommand 'show:users:search'
    'click .showUsersNearby': _.clickCommand 'show:users:nearby'

    'click .searchGroups': _.clickCommand 'show:groups:search'
    'click .createGroup': _.clickCommand 'create:group'
    'click .showGroupsNearby': _.clickCommand 'show:groups:nearby'

  showUsersMenu: ->
    @ui.showUsersMenu.hide()
    @ui.userMenu.removeClass 'force-hidden'

  showGroupsMenu: (e)->
    @ui.showGroupsMenu.hide()
    @ui.groupMenu.removeClass 'force-hidden'
