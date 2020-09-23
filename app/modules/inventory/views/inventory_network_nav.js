/* eslint-disable
    import/no-duplicates,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import InventoryCommonNav from 'modules/inventory/views/inventory_common_nav'

export default InventoryCommonNav.extend({
  id: 'inventoryNetworkNav',
  template: require('./templates/inventory_network_nav'),

  behaviors: {
    PreventDefault: {}
  },

  ui: {
    showUsersMenu: '.showUsersMenu',
    showGroupsMenu: '.showGroupsMenu',
    userMenu: '.userMenu',
    groupMenu: '.groupMenu'
  },

  onShow () {
    app.request('fetch:friends')
    .then(() => this.showList(this.usersList, app.users.filtered.friends()))

    return app.request('wait:for', 'groups')
    .then(() => this.showList(this.groupsList, app.groups))
  },

  events: {
    'click .showUsersMenu': 'showUsersMenu',
    'click .showGroupsMenu': 'showGroupsMenu',

    'click .inviteByEmail': _.clickCommand('show:invite:friend:by:email'),
    'click .searchUsers': _.clickCommand('show:users:search'),
    'click .showUsersNearby': _.clickCommand('show:users:nearby'),

    'click .searchGroups': _.clickCommand('show:groups:search'),
    'click .createGroup': _.clickCommand('create:group'),
    'click .showGroupsNearby': _.clickCommand('show:groups:nearby')
  },

  showUsersMenu () {
    this.ui.showUsersMenu.hide()
    return this.ui.userMenu.removeClass('force-hidden')
  },

  showGroupsMenu (e) {
    this.ui.showGroupsMenu.hide()
    return this.ui.groupMenu.removeClass('force-hidden')
  }
})
