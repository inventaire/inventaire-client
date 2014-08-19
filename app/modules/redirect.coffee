module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        "*route": "redirectHome"

    API =
      redirectHome: (route)->
        _.log route, 'route:redirectHome'
        app.goTo 'inventory'

    app.addInitializer ->
      new Router
        controller: API