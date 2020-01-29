ShelfLayout = require './views/shelf_layout'
ShelvesLayout = require './views/shelves_layout'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'shelves(/)(:username)(/)': 'showShelves'
        'shelf/(:id)(/)': 'showShelf'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    app.commands.setHandlers
      'show:shelf': API.showShelf
      'show:shelves': API.showShelves

API =
  showShelf: (shelf)->
    if app.request 'require:loggedIn', 'shelves'
      app.layout.main.show new ShelfLayout { shelf }

  showShelves: (username) ->
    if app.request 'require:loggedIn', 'shelves'
      app.layout.main.show new ShelvesLayout { username }

