module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        '(signup)(/*whatever)(/)': 'home'
        '(login)(/)': 'home'
        '*route': 'notFound'

    app.addInitializer ->
      new Router
        controller: API

API =
  home: -> app.execute 'show:home'
  notFound: (route)->
    _.log route, 'route:notFound'
    app.execute 'show:404'