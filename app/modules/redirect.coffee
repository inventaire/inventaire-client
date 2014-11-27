module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        '': 'root'
        '*route': 'notFound'

    app.addInitializer ->
      new Router
        controller: API

  initialize: ->
    app.commands.setHandlers
      'show:home': API.root.bind API

API =
  root: ->
    if app.user.loggedIn
      app.execute 'show:inventory:personal'
    else @showWelcome()


  notFound: (route)->
    if app.user.loggedIn
      _.log route, 'route:notFound', true
      app.execute 'show:404'
    else @showWelcome()

  showWelcome: ->
    app.layout.main.show new app.View.Welcome
    app.navigate 'welcome'