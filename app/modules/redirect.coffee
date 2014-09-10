module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        '*route': 'redirectHome'

    app.addInitializer ->
      new Router
        controller: API

API =
  redirectHome: (route)->
    _.log route, 'route:redirectHome'
    app.goTo 'inventory'