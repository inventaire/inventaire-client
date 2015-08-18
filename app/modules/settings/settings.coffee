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
  title = _.I18n 'settings'
  options = {model: app.user, tab: tab}
  app.layout.main.show new SettingsLayout(options), title

setHandlers = ->
  app.commands.setHandlers
    'show:settings:profile': ->
      API.showProfileSettings()
      app.navigate 'settings/profile'

    'show:settings:labs': ->
      API.showLabsSettings()
      app.navigate 'settings/labs'