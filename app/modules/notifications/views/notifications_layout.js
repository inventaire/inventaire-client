UsersList = require 'modules/users/views/users_list'
GroupsList = require 'modules/network/views/groups_list'

NotificationsList = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: require './notification_li'
  emptyView: require './no_notification'

  onShow: ->
    # Wait for the notifications to arrive to mark them as read
    app.request 'wait:for', 'user'
    .then @collection.markAsRead.bind(@collection)

module.exports = Marionette.LayoutView.extend
  id: 'notificationsLayout'
  template: require './templates/notifications_layout'
  childViewContainer: 'ul'

  regions:
    friendsRequestsList: '#friendsRequestsList'
    groupsInvitationsList: '#groupsInvitationsList'
    notificationsList: '#notificationsList'

  ui:
    friendsRequestsSection: '.friendsRequests'
    groupsInvitationsSection: '.groupsInvitations'

  initialize: ->
    { @notifications } = @options

    @waitForFriendsRequests = app.request 'fetch:otherRequested'
      .then => @otherRequested = app.users.otherRequested

    @waitForGroupsInvitations = app.request 'wait:for', 'groups'

  behaviors:
    PreventDefault: {}

  onShow: ->
    @waitForFriendsRequests
    .then @ifViewIsIntact('showFriendsRequests')

    @waitForGroupsInvitations
    .then @ifViewIsIntact('showGroupsInvitations')

    @showNotificationsList()

  events:
    'click .showNotificationsSettings': _.clickCommand 'show:settings:notifications'

  showFriendsRequests: ->
    if @otherRequested.length > 0
      @ui.friendsRequestsSection.removeClass 'hidden'
      @friendsRequestsList.show new UsersList
        collection: @otherRequested
        emptyViewMessage: 'no pending requests'
        stretch: true

  showGroupsInvitations: ->
    if app.groups.mainUserInvited.length > 0
      @ui.groupsInvitationsSection.removeClass 'hidden'
      @groupsInvitationsList.show new GroupsList { collection: app.groups.mainUserInvited }

  showNotificationsList: ->
    @notificationsList.show new NotificationsList { collection: @notifications }
