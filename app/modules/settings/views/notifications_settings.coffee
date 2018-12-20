notificationsList = require '../lib/notifications_settings_list'
getPeriodicityDays = require '../lib/periodicity_days'
defaultPeriodicity = 20

module.exports = Marionette.ItemView.extend
  template: require './templates/notifications_settings'
  className: 'notificationsSettings'
  initialize: ->
    @lazyRender = _.LazyRender @
    @listenTo app.user, 'rollback', @lazyRender

  behaviors:
    # autofocus doesn't really seem to work here :/
    AutoFocus: {}
    SuccessCheck: {}
    Toggler: {}

  serializeData: ->
    notifications = app.user.get 'settings.notifications'
    summaryPeriodicity = app.user.get('summaryPeriodicity') or defaultPeriodicity
    _.extend @getNotificationsData(notifications),
      warning: 'global_email_toggle_warning'
      showWarning: not notifications.global
      showPeriodicity: not notifications.inventories_activity_summary
      days: getPeriodicityDays summaryPeriodicity

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
    globalFog: '.rest-fog'
    periodicityFog: '.periodicity-fog'

  events:
    'change .toggler-input': 'toggleSetting'
    'change #periodicityPicker': 'updatePeriodicity'

  toggleSetting: (e)->
    { id, checked } = e.currentTarget
    @updateSetting id, checked

  updateSetting: (id, value)->
    app.request 'user:update',
      attribute: "settings.notifications.#{id}",
      value: value
      defaultPreviousValue: true

    if id is 'global' then @toggleWarning()
    if id is 'inventories_activity_summary' then @togglePeriodicity()

  toggleWarning: ->
    @ui.warning.slideToggle 200
    @ui.globalFog.fadeToggle 200

  togglePeriodicity: ->
    @ui.periodicityFog.fadeToggle 200

  updatePeriodicity: (e)->
    value = parseInt e.target.value
    app.request 'user:update',
      attribute: 'summaryPeriodicity'
      value: value
      selector: '#periodicityPicker'
