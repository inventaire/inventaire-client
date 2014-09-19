module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        '*route': 'notFound'

    app.addInitializer ->
      new Router
        controller: API

API =
  notFound: (route)->
    _.log route, 'route:notFound'
    app.execute 'show:404'