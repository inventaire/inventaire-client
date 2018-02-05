Notifications = require './collections/notifications'
NotificationsLayout = require './views/notifications_layout'
notifications = new Notifications
waitForNotifications = null

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'notifications(/)': 'showNotifications'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    app.commands.setHandlers
      'show:notifications': API.showNotifications

    app.reqres.setHandlers
      'notifications:unread:count': -> notifications.unreadCount()

    if app.user.loggedIn
      waitForNotifications = _.preq.get app.API.notifications
        .then notifications.addPerType.bind(notifications)
        .catch _.Error('notifications init err')

API =
  showNotifications: ->
    if app.request 'require:loggedIn', 'notifications'
      app.execute 'show:loader'
      # Make sure that the notifications arrived before calling 'beforeShow'
      # as it will only trigger 'beforeShow' on the notifications models
      # presently in the collection
      waitForNotifications
      .then -> notifications.beforeShow()
      .then ->
        app.layout.main.show new NotificationsLayout { collection: notifications }
        app.navigate 'notifications',
          metadata: { title: _.i18n('notifications') }
