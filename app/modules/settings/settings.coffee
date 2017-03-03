SettingsLayout = require './views/settings'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'settings(/profile)(/)': 'showProfileSettings'
        'settings/notifications(/)': 'showNotificationsSettings'
        'settings/labs(/)': 'showLabsSettings'

    app.addInitializer -> new Router { controller: API }

  initialize: -> setHandlers()

API =
  showProfileSettings: -> showSettings 'profile'
  showNotificationsSettings: -> showSettings 'notifications'
  showLabsSettings: -> showSettings 'labs'

showSettings = (tab)->
  if app.request 'require:loggedIn', "settings/#{tab}"
    app.layout.main.show new SettingsLayout { model: app.user, tab }

setHandlers = ->
  app.commands.setHandlers
    'show:settings:profile': API.showProfileSettings
    'show:settings:notifications': API.showNotificationsSettings
    'show:settings:labs': API.showLabsSettings
