NetworkLayout = require './views/network_layout'
initGroupHelpers = require './lib/group_helpers'

module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'network': 'showNetworkLayout'

    app.addInitializer ->
      new Router
        controller: API

  initialize: ->
    app.commands.setHandlers
      'show:network': API.showNetworkLayout

    app.request('waitForUserData')
    .then initGroupHelpers

API =
  showNetworkLayout: ->
    app.layout.main.Show new NetworkLayout
      title: _.i18n 'network'
    app.navigate 'network'
