ShelfLayout = require './views/shelf_layout'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'shelves(/)(:id)(/)': 'showShelf'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    app.commands.setHandlers
      'show:shelf': API.showShelf

API =
  showShelf: (shelf)->
    if app.request 'require:loggedIn', 'shelves'
      app.layout.main.show new ShelfLayout { shelf }

