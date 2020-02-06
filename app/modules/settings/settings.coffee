SettingsLayout = require './views/settings'
screen_ = require 'lib/screen'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'settings(/profile)(/)': 'showProfileSettings'
        'settings/account(/)': 'showAccountSettings'
        'settings/notifications(/)': 'showNotificationsSettings'
        'settings/data(/)': 'showDataSettings'
        # Legacy
        'settings/labs(/)': 'showDataSettings'
        'menu(/)': 'showProfileSettings'

    app.addInitializer -> new Router { controller: API }

  initialize: -> setHandlers()

API =
  showProfileSettings: -> showSettings 'profile'
  showAccountSettings: -> showSettings 'account'
  showNotificationsSettings: -> showSettings 'notifications'
  showDataSettings: -> showSettings 'data'

showSettings = (tab)->
  if app.request 'require:loggedIn', "settings/#{tab}"
    app.layout.main.show new SettingsLayout { model: app.user, tab }

setHandlers = ->
  app.commands.setHandlers
    'show:settings': API.showProfileSettings
    'show:settings:profile': API.showProfileSettings
    'show:settings:account': API.showAccountSettings
    'show:settings:notifications': API.showNotificationsSettings
    'show:settings:data': API.showDataSettings
