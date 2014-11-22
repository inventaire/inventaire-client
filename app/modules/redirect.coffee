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
  home: (route)->
    _.log route, 'route:redirect'
    app.execute 'show:home'
  notFound: (route)->
    if app.user.loggedIn
      _.log route, 'route:notFound'
      app.execute 'show:404'
    else @showWelcome()

  showWelcome: ->
    app.layout.main.show new app.View.Welcome
    app.navigate 'welcome'