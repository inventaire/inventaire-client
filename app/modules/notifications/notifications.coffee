Notifications = require './collections/notifications'
NotificationsList = require './views/notifications_list'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->

  initialize: ->
    notif = {title : 'hello notifs!'}
    @notifications = app.user.notifications = new Notifications

    app.reqres.setHandlers
      'notifications:list': API.notificationsList.bind(@)
      'notifications:add': API.addNotification.bind(@)

API =
  notificationsList: ->
    new NotificationsList {collection: @notifications, el: '#notifications'}

  addNotification: (notification)->
    @notifications.add notification