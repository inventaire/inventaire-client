notificationsList = sharedLib 'notifications_settings_list'

module.exports = Marionette.ItemView.extend
  template: require './templates/notifications_settings'
  className: 'notificationsSettings'
  initialize: ->
    # used here to delay the rendering once 'user:ready' is triggered
    @lazyRender = _.LazyRender @
    @listenTo app.user, 'change:settings', @lazyRender

  serializeData: ->
    notifications = app.user.get 'settings.notifications'
    _.extend @getNotificationsData(notifications),
      warning: 'global_email_toggle_warning'
      showWarning: not notifications.global

  getNotificationsData: (notifications)->
    data = {}
    for notif in notificationsList
      data[notif] =
        id: notif
        checked: notifications[notif] isnt false
        label: "#{notif}_notification"
    return data

  ui:
    global: '#global'
    warning: '.warning'
    fog: '.local-fog'

  events:
    'change .toggler-input': 'toggleSetting'

  toggleSetting: (e)->
    { id, checked } = e.currentTarget
    @updateSetting id, checked

  updateSetting: (id, value)->
    app.request 'user:update',
      attribute: "settings.notifications.#{id}",
      value: value
      defaultPreviousValue: true

    if id is 'global' then @toggleWarning()

  toggleWarning: ->
    @ui.warning.slideToggle(200)
    @ui.fog.fadeToggle(200)
