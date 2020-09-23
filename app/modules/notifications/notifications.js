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

    waitForNotifications = getNotificationsData()

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
        app.layout.main.show new NotificationsLayout { notifications }
        app.navigate 'notifications',
          metadata: { title: _.i18n('notifications') }

getNotificationsData = ->
  unless app.user.loggedIn then return Promise.resolve()

  _.preq.get app.API.notifications
  .get 'notifications'
  .then notifications.addPerType.bind(notifications)
  .catch _.ErrorRethrow('notifications init err')
