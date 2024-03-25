import PreventDefault from '#behaviors/prevent_default'
import GroupsList from '#groups/views/groups_list'
import { clickCommand } from '#lib/utils'
import UsersList from '#users/views/users_list'
import NoNotification from './no_notification.ts'
import NotificationLi from './notification_li.ts'
import notificationsLayoutTemplate from './templates/notifications_layout.hbs'
import '../scss/notifications_layout.scss'

const NotificationsList = Marionette.CollectionView.extend({
  tagName: 'ul',
  childView: NotificationLi,
  emptyView: NoNotification,

  onRender () {
    // Wait for the notifications to arrive to mark them as read
    app.request('wait:for', 'user')
    .then(this.collection.markAsRead.bind(this.collection))
  },
})

export default Marionette.View.extend({
  id: 'notificationsLayout',
  template: notificationsLayoutTemplate,
  childViewContainer: 'ul',

  regions: {
    friendsRequestsList: '#friendsRequestsList',
    groupsInvitationsList: '#groupsInvitationsList',
    notificationsList: '#notificationsList',
  },

  ui: {
    friendsRequestsSection: '.friendsRequests',
    groupsInvitationsSection: '.groupsInvitations',
  },

  initialize () {
    this.notifications = this.options.notifications

    this.waitForFriendsRequests = app.request('fetch:otherRequested')
      .then(() => { this.otherRequested = app.users.otherRequested })

    this.waitForGroupsInvitations = app.request('wait:for', 'groups')
  },

  behaviors: {
    PreventDefault,
  },

  onRender () {
    this.waitForFriendsRequests
    .then(this.ifViewIsIntact('showFriendsRequests'))

    this.waitForGroupsInvitations
    .then(this.ifViewIsIntact('showGroupsInvitations'))

    this.showNotificationsList()
  },

  events: {
    'click .showNotificationsSettings': clickCommand('show:settings:notifications'),
  },

  showFriendsRequests () {
    if (this.otherRequested.length > 0) {
      this.ui.friendsRequestsSection.removeClass('hidden')
      this.showChildView('friendsRequestsList', new UsersList({
        collection: this.otherRequested,
        emptyViewMessage: 'no pending requests',
        stretch: true,
      }))
    }
  },

  showGroupsInvitations () {
    if (app.groups.mainUserInvited.length > 0) {
      this.ui.groupsInvitationsSection.removeClass('hidden')
      this.showChildView('groupsInvitationsList', new GroupsList({ collection: app.groups.mainUserInvited }))
    }
  },

  showNotificationsList () {
    this.showChildView('notificationsList', new NotificationsList({ collection: this.notifications }))
  },
})
