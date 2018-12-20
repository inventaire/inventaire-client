SettingsMenu = require './views/settings_menu'
SettingsLayout = require './views/settings'
screen_ = require 'lib/screen'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'menu(/)': 'showSettingsMenu'
        'settings(/profile)(/)': 'showProfileSettings'
        'settings/notifications(/)': 'showNotificationsSettings'
        'settings/labs(/)': 'showLabsSettings'

    app.addInitializer -> new Router { controller: API }

  initialize: -> setHandlers()

API =
  showSettingsMenu: ->
    if screen_.isSmall()
      app.layout.main.show new SettingsMenu
    else
      app.layout.modal.show new SettingsMenu { navigateOnClose: true }
      app.execute 'modal:open', null, null, true

    app.navigate 'menu', { metadata: { title: 'menu' } }

  showProfileSettings: -> showSettings 'profile'
  showNotificationsSettings: -> showSettings 'notifications'
  showLabsSettings: -> showSettings 'labs'

showSettings = (tab)->
  if app.request 'require:loggedIn', "settings/#{tab}"
    app.layout.main.show new SettingsLayout { model: app.user, tab }

setHandlers = ->
  app.commands.setHandlers
    'show:settings:menu': API.showSettingsMenu
    'show:settings:profile': API.showProfileSettings
    'show:settings:notifications': API.showNotificationsSettings
    'show:settings:labs': API.showLabsSettings
