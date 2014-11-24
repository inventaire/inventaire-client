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
    if app.user.loggedIn
      _.log route, 'route:notFound', true
      app.execute 'show:404'
    else @showWelcome()

  showWelcome: ->
    app.layout.main.show new app.View.Welcome
    app.navigate 'welcome'