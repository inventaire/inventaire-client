SettingsMenu = require './views/settings_menu'
SettingsLayout = require './views/settings'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'settings(/)': 'showSettingsMenu'
        'settings(/profile)(/)': 'showProfileSettings'
        'settings/notifications(/)': 'showNotificationsSettings'
        'settings/labs(/)': 'showLabsSettings'

    app.addInitializer -> new Router { controller: API }

  initialize: -> setHandlers()

API =
  showSettingsMenu: ->
    if _.smallScreen()
      app.layout.main.show new SettingsMenu
    else
      options =
        navigateOnClose:
          route: _.currentRoute()
          title: document.title

      app.layout.modal.show new SettingsMenu options
      app.execute 'modal:open', null, null, true

    app.navigate 'settings', { metadata: { title: 'settings' } }

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
