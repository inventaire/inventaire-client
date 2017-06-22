module.exports = Marionette.CompositeView.extend
  id: 'notificationsLayout'
  childView: require './notification_li'
  emptyView: require './no_notification'
  template: require './templates/notifications_layout'
  childViewContainer: 'ul'

  behaviors:
    PreventDefault: {}

  initialize:->
    @collection = app.notifications

  onShow: ->
    # Wait for the notifications to arrive to mark them as read
    app.request 'wait:for', 'user'
    .then @collection.markAsRead.bind(@collection)

  events:
    # 'click a[href="/settings/notifications"]': 'showNotificationsSettings'
    'click .showNotificationsSettings': 'showNotificationsSettings'

  showNotificationsSettings: (e)->
    unless _.isOpenedOutside e then app.execute 'show:settings:notifications'
