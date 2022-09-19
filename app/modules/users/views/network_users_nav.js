import { clickCommand } from '#lib/utils'
import InventoryCommonNav from '#users/views/users_home_sections_common_nav'
import networkUsersNavTemplate from './templates/network_users_nav.hbs'
import PreventDefault from '#behaviors/prevent_default'

export default InventoryCommonNav.extend({
  id: 'networkUsersNav',
  template: networkUsersNavTemplate,

  behaviors: {
    PreventDefault,
  },

  ui: {
    showUsersMenu: '.showUsersMenu',
    showGroupsMenu: '.showGroupsMenu',
    userMenu: '.userMenu',
    groupMenu: '.groupMenu'
  },

  onRender () {
    app.request('fetch:friends')
    .then(() => this.showList('usersList', app.users.filtered.friends()))

    app.request('wait:for', 'groups')
    .then(() => this.showList('groupsList', app.groups))
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
