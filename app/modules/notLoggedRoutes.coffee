module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        '*route': 'showWelcome'

    API =
      showWelcome: ->
        app.layout.main.show new app.View.Welcome
        app.navigate 'welcome'

    app.addInitializer ->
      new Router
        controller: API

    app.commands.setHandlers
      'show:welcome': API.showWelcome