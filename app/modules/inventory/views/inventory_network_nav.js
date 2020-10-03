import { clickCommand } from 'lib/utils'
import InventoryCommonNav from 'modules/inventory/views/inventory_common_nav'

export default InventoryCommonNav.extend({
  id: 'inventoryNetworkNav',
  template: require('./templates/inventory_network_nav.hbs'),

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

    'click .inviteByEmail': clickCommand('show:invite:friend:by:email'),
    'click .searchUsers': clickCommand('show:users:search'),
    'click .showUsersNearby': clickCommand('show:users:nearby'),

    'click .searchGroups': clickCommand('show:groups:search'),
    'click .createGroup': clickCommand('create:group'),
    'click .showGroupsNearby': clickCommand('show:groups:nearby')
  },

  showUsersMenu () {
    this.ui.showUsersMenu.hide()
    this.ui.userMenu.removeClass('force-hidden')
  },

  showGroupsMenu (e) {
    this.ui.showGroupsMenu.hide()
    this.ui.groupMenu.removeClass('force-hidden')
  }
})
