module.exports = Marionette.ItemView.extend
  template: require './templates/notifications_settings'
  className: 'notificationsSettings'
  initialize: ->
    # used here to delay the rendering once 'user:ready' is triggered
    @lazyRender = _.debounce @render.bind(@), 200
    @listenTo app.user, 'change:settings', @lazyRender

  serializeData: ->
    { global } = app.user.get('settings.notifications')
    return data =
      globalEmailsToggler:
        id: 'globalEmails'
        checked: global
      warning: 'global_email_toggle_warning'
      showWarning: not global

  ui:
    globalEmails: '#globalEmails'
    warning: '.warning'

  events:
    'change #globalEmails': 'toggleGlobalEmails'

  toggleGlobalEmails: ->
    app.request 'user:update',
      attribute: 'settings.notifications.global',
      value: @ui.globalEmails[0].checked
      defaultPreviousValue: true

    @toggleWarning()

  toggleWarning: -> @ui.warning.slideToggle(200)
