SettingsLayout = require './views/settings'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    SettingsRouter = Marionette.AppRouter.extend
      appRoutes:
        'settings(/profile)(/)': 'showProfileSettings'
        'settings/notifications(/)': 'showNotificationsSettings'
        'settings/labs(/)': 'showLabsSettings'

    app.addInitializer ->
      new SettingsRouter
        controller: API

  initialize: -> setHandlers()

API =
  showProfileSettings: -> showSettings 'profile'
  showNotificationsSettings: -> showSettings 'notifications'
  showLabsSettings: -> showSettings 'labs'

showSettings = (tab)->
  if app.request 'require:loggedIn', "settings/#{tab}"
    title = _.I18n 'settings'
    options = {model: app.user, tab: tab}
    app.layout.main.Show new SettingsLayout(options), title

setHandlers = ->
  app.commands.setHandlers
    'show:settings:profile': API.showProfileSettings
    'show:settings:notifications': API.showNotificationsSettings
    'show:settings:labs': API.showLabsSettings
