module.exports = Marionette.CompositeView.extend
  id: 'notificationsLayout'
  childView: require './notification_li'
  emptyView: require './no_notification'
  template: require './templates/notifications_layout'
  childViewContainer: 'ul'

  initialize:->
    @collection = app.user.notifications
