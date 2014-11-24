Notifications = require './collections/notifications'
NotificationsList = require './views/notifications_list'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->

  initialize: ->
    @notifications = app.user.notifications = new Notifications

    app.reqres.setHandlers
      'notifications:add': API.addNotification.bind(@)

API =
  addNotification: (notification)->
    _.log notification, 'notifications:add'
    @notifications.add notification