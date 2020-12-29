import notificationsList from '../lib/notifications_settings_list'
import getPeriodicityDays from '../lib/periodicity_days'
import notificationsSettingsTemplate from './templates/notifications_settings.hbs'

const defaultPeriodicity = 20

export default Marionette.ItemView.extend({
  template: notificationsSettingsTemplate,
  className: 'notificationsSettings',
  initialize () {
    this.listenTo(app.user, 'rollback', this.lazyRender.bind(this))
  },

  behaviors: {
    // autofocus doesn't really seem to work here :/
    AutoFocus: {},
    SuccessCheck: {},
    Toggler: {}
  },

  serializeData () {
    const notifications = app.user.get('settings.notifications') || {}
    const summaryPeriodicity = app.user.get('summaryPeriodicity') || defaultPeriodicity
    return _.extend(this.getNotificationsData(notifications), {
      warning: 'global_email_toggle_warning',
      showWarning: !notifications.global,
      showPeriodicity: !notifications.inventories_activity_summary,
      days: getPeriodicityDays(summaryPeriodicity)
    })
  },

  getNotificationsData (notifications) {
    const data = {}
    for (const notif of notificationsList) {
      data[notif] = {
        id: notif,
        checked: notifications[notif] !== false,
        label: `${notif}_notification`
      }
    }
    return data
  },

  ui: {
    global: '#global',
    warning: '.warning',
    globalFog: '.rest-fog',
    periodicityFog: '.periodicity-fog'
  },

  events: {
    'change .toggler-input': 'toggleSetting',
    'change #periodicityPicker': 'updatePeriodicity'
  },

  toggleSetting (e) {
    const { id, checked } = e.currentTarget
    return this.updateSetting(id, checked)
  },

  updateSetting (id, value) {
    app.request('user:update', {
      attribute: `settings.notifications.${id}`,
      value,
      defaultPreviousValue: true
    })

    if (id === 'global') this.toggleWarning()
    if (id === 'inventories_activity_summary') return this.togglePeriodicity()
  },

  toggleWarning () {
    this.ui.warning.slideToggle(200)
    this.ui.globalFog.fadeToggle(200)
  },

  togglePeriodicity () {
    this.ui.periodicityFog.fadeToggle(200)
  },

  updatePeriodicity (e) {
    const value = parseInt(e.target.value)
    return app.request('user:update', {
      attribute: 'summaryPeriodicity',
      value,
      selector: '#periodicityPicker'
    })
  }
})
