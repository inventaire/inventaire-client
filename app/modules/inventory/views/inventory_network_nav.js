import { clickCommand } from 'lib/utils'
import InventoryCommonNav from 'modules/inventory/views/inventory_common_nav'
import inventoryNetworkNavTemplate from './templates/inventory_network_nav.hbs'

export default InventoryCommonNav.extend({
  id: 'inventoryNetworkNav',
  template: inventoryNetworkNavTemplate,

  behaviors: {
    PreventDefault: {}
  },

  regions: {
    usersList: '#usersList',
    groupsList: '#groupsList',
    friendRequestsList: '#friendRequestsList',
    groupsInvitationsList: '#groupsInvitationsList',
  },

  ui: {
    showUsersMenu: '.showUsersMenu',
    showGroupsMenu: '.showGroupsMenu',
    userMenu: '.userMenu',
    groupMenu: '.groupMenu',
    friendRequestsWrapper: '.friendRequestsWrapper',
    groupsInvitationsWrapper: '.groupsInvitationsWrapper',
  },

  async onShow () {
    await Promise.all([
      app.request('fetch:friends'),
      app.request('fetch:otherRequested'),
      app.request('wait:for', 'groups'),
    ])

    this.showList(this.usersList, app.users.friends)
    if (app.users.otherRequested.length > 0) {
      this.showList(this.friendRequestsList, app.users.otherRequested)
      this.ui.friendRequestsWrapper.removeClass('hidden')
    }

    this.showList(this.groupsList, app.groups.mainUserMember)
    if (app.groups.mainUserInvited.length > 0) {
      this.showList(this.groupsInvitationsList, app.groups.mainUserInvited)
      this.ui.groupsInvitationsWrapper.removeClass('hidden')
    }
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
