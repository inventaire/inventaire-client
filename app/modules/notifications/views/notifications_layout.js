/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import UsersList from 'modules/users/views/users_list'
import GroupsList from 'modules/network/views/groups_list'

const NotificationsList = Marionette.CollectionView.extend({
  tagName: 'ul',
  childView: require('./notification_li'),
  emptyView: require('./no_notification'),

  onShow () {
    // Wait for the notifications to arrive to mark them as read
    return app.request('wait:for', 'user')
    .then(this.collection.markAsRead.bind(this.collection))
  }
})

export default Marionette.LayoutView.extend({
  id: 'notificationsLayout',
  template: require('./templates/notifications_layout'),
  childViewContainer: 'ul',

  regions: {
    friendsRequestsList: '#friendsRequestsList',
    groupsInvitationsList: '#groupsInvitationsList',
    notificationsList: '#notificationsList'
  },

  ui: {
    friendsRequestsSection: '.friendsRequests',
    groupsInvitationsSection: '.groupsInvitations'
  },

  initialize () {
    ({ notifications: this.notifications } = this.options)

    this.waitForFriendsRequests = app.request('fetch:otherRequested')
      .then(() => { return this.otherRequested = app.users.otherRequested })

    return this.waitForGroupsInvitations = app.request('wait:for', 'groups')
  },

  behaviors: {
    PreventDefault: {}
  },

  onShow () {
    this.waitForFriendsRequests
    .then(this.ifViewIsIntact('showFriendsRequests'))

    this.waitForGroupsInvitations
    .then(this.ifViewIsIntact('showGroupsInvitations'))

    return this.showNotificationsList()
  },

  events: {
    'click .showNotificationsSettings': _.clickCommand('show:settings:notifications')
  },

  showFriendsRequests () {
    if (this.otherRequested.length > 0) {
      this.ui.friendsRequestsSection.removeClass('hidden')
      return this.friendsRequestsList.show(new UsersList({
        collection: this.otherRequested,
        emptyViewMessage: 'no pending requests',
        stretch: true
      })
      )
    }
  },

  showGroupsInvitations () {
    if (app.groups.mainUserInvited.length > 0) {
      this.ui.groupsInvitationsSection.removeClass('hidden')
      return this.groupsInvitationsList.show(new GroupsList({ collection: app.groups.mainUserInvited }))
    }
  },

  showNotificationsList () {
    return this.notificationsList.show(new NotificationsList({ collection: this.notifications }))
  }
})
