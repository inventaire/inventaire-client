Notifications = require './collections/notifications'
NotificationsList = require './views/notifications_list'
NotificationsLayout = require './views/notifications_layout'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'notifications': 'showNotifications'

    app.addInitializer ->
      new Router
        controller: API

  initialize: ->
    notifications = app.user.notifications = new Notifications

    addNotifications = (notifs)->
      _.log notifs, 'notifications:add'
      getUsersData notifs
      .then _.Full(notifications.addPerType, notifications, notifs)
      .catch _.Error('addNotifications')

    app.commands.setHandlers
      'show:notifications': ->
        API.showNotifications()
        app.navigate 'notifications'

    _.preq.get app.API.notifs
    .tap app.Request('waitForData')
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
      app.layout.main.Show new NotificationsLayout,
        docTitle: _.i18n 'notifications'
