module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        '': 'showHome'
        '*route': 'notFound'

    app.addInitializer ->
      new Router
        controller: API

  initialize: ->
    app.commands.setHandlers
      'show:home': API.showHome
      'show:welcome': API.showWelcome
      'show:error': API.showError
      'show:403': API.show403
      'show:404': API.show404

API =
  showHome: ->
    if app.user.loggedIn
      app.execute 'show:inventory:personal'
    else app.execute 'show:welcome'

  notFound: (route)->
    if app.user.loggedIn
      _.log route, 'route:notFound', true
      app.execute 'show:404'
    else @showWelcome()

  showWelcome: ->
    app.layout.main.show new app.View.Welcome
    app.navigate 'welcome'

  show403: ->
    app.execute 'show:error',
      code: 403
      message: _.i18n 'Forbidden'

  show404: ->
    app.execute 'show:error',
      code: 404
      message: _.i18n 'Not Found'

  showError: (options)->
    app.layout.main.show new app.View.Error options