SettingsLayout = require './views/settings'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    SettingsRouter = Marionette.AppRouter.extend
      appRoutes:
        'settings(/profile)(/)': 'showProfileSettings'
        'settings/labs(/)': 'showLabsSettings'

    app.addInitializer ->
      new SettingsRouter
        controller: API

  initialize: -> setHandlers()

API =
  showProfileSettings: -> showSettings 'profile'
  showLabsSettings: -> showSettings 'labs'

showSettings = (tab)->
  app.layout.main.show new SettingsLayout {model: app.user, tab: tab}

setHandlers = ->
  app.commands.setHandlers
    'show:user:edit:settings': (tab)->
      API.showProfileSettings()
      app.navigate 'settings/edit'

    'show:user:edit:labs': (tab)->
      API.showLabsSettings()
      app.navigate 'settings/edit/labs'