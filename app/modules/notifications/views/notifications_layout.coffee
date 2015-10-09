NotificationsList = require './notifications_list'

module.exports = Marionette.LayoutView.extend
  id: 'notificationsLayout'
  template: require './templates/notifications_layout'
  regions:
    list: '#list'

  initialize:->
    @notifications = app.user.notifications


  onShow:->
    app.request 'waitForData'
    .then @showNotifications.bind(@)

  showNotifications: ->
    @list.show new NotificationsList
      collection: @notifications
