module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        '*route': 'notLoggedUser'

    API =
      notLoggedUser: (route)->
        _.log route, 'route:notLoggedUser'
        app.welcome ||= new app.View.Welcome
        app.layout.main.show app.welcome
        app.navigate 'welcome'

    app.addInitializer ->
      new Router
        controller: API