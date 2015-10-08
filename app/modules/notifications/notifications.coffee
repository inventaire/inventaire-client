Notifications = require './collections/notifications'
NotificationsList = require './views/notifications_list'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->

  initialize: ->
    notifications = app.user.notifications = new Notifications

    addNotifications = (notifs)->
      _.log notifs, 'notifications:add'
      getUsersData notifs
      .then _.Full(notifications.addPerType, notifications, notifs)
      .catch _.Error('addNotifications')

    app.reqres.setHandlers
      'notifications:add': addNotifications.bind(@)
      'show:notifications'


getUsersData = (notifications)->
  ids = getUsersIds notifications
  app.request 'get:users:data', ids

getUsersIds = (notifications)->
  ids = notifications.map (notif)-> notif.data.user
