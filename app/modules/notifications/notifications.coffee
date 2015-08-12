Notifications = require './collections/notifications'
NotificationsList = require './views/notifications_list'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->

  initialize: ->
    @notifications = app.user.notifications = new Notifications

    app.reqres.setHandlers
      'notifications:add': API.addNotifications.bind(@)

API =
  addNotifications: (notifications)->
    # _.log notifications, 'notifications:add'
    API.getUsersData(notifications)
    .then ()=> @notifications.add notifications

  getUsersData: (notifications)->
    ids = API.getUsersIds(notifications)
    app.request('get:users:data', ids)

  getUsersIds: (notifications)->
    ids = notifications.map (notif)-> notif.data.user