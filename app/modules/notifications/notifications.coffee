Notifications = require './collections/notifications'
NotificationsList = require './views/notifications_list'
NotificationsLayout = require './views/notifications_layout'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'notifications': 'showNotifications'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    notifications = app.notifications = new Notifications

    addNotifications = (notifs)->
      getUsersData notifs
      .then _.Full(notifications.addPerType, notifications, notifs)
      .catch _.Error('addNotifications')

    app.commands.setHandlers
      'show:notifications': API.showNotifications

    if app.user.loggedIn
      _.preq.get app.API.notifs
      .tap app.Request('waitForNetwork')
      .then addNotifications
      .catch _.Error('notifications init err')

getUsersData = (notifications)->
  ids = getUsersIds notifications
  app.request 'get:users:data', ids

getUsersIds = (notifications)->
  ids = notifications.map (notif)-> notif.data.user
  return _.uniq ids

API =
  showNotifications: ->
    if app.request 'require:loggedIn', 'notifications'
      app.layout.main.show new NotificationsLayout
      app.navigate 'notifications',
        metadata:
          title: _.i18n 'notifications'
