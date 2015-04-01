Welcome = require 'modules/welcome/views/welcome'
ErrorView = require 'modules/general/views/error'
initQuerystringActions = require 'modules/general/lib/querystring_actions'

module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        '(home)': 'showHome'
        'welcome': 'showWelcome'
        '*route': 'notFound'

    app.addInitializer ->
      new Router
        controller: API

  initialize: ->
    app.reqres.setHandlers
      'require:loggedIn': API.requireLoggedIn

    app.commands.setHandlers
      'show:home': API.showHome
      'show:welcome': API.showWelcome
      'show:error': API.showError
      'show:403': API.show403
      'show:404': API.show404
      'show:offline:error': API.showOfflineError

    initQuerystringActions()

API =
  requireLoggedIn: (route)->
    _.log app.user.loggedIn, 'app.user.loggedIn'
    if app.user.loggedIn then return true
    else
      app.execute 'show:login'
      app.execute 'prepare:login:redirect', route
      return false

  showHome: ->
    if app.user.loggedIn
      app.execute 'show:inventory:general'
    else app.execute 'show:welcome'

  notFound: (route)->
    if app.user.loggedIn
      _.log route, 'route:notFound', true
      app.execute 'show:404'
    else @showWelcome()

  showWelcome: ->
    app.layout.main.show new Welcome
    app.navigate 'welcome'

  show403: ->
    app.execute 'show:error',
      code: 403
      message: _.i18n 'forbidden'

  show404: ->
    app.execute 'show:error',
      code: 404
      message: _.i18n 'not found'

  showOfflineError: ->
    app.execute 'show:error',
      message: _.i18n("can't reach the server")

  showError: (options)->
    _.log options, 'showError', true
    app.layout.main.show new ErrorView options