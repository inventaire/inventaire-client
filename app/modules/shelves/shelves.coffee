InventoryLayout = require '../inventory/views/inventory_layout'
{ getById } = require './lib/shelf'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'shelf/(:id)(/)': 'showShelf'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    app.commands.setHandlers
      'show:shelf': API.showShelf

API =
  showShelf: (shelfId)->
    Promise.try -> getById(shelfId)
    .then (shelf)->
      user = shelf.get('owner')
      if app.request 'require:loggedIn', 'shelves'
        app.layout.main.show new InventoryLayout { shelf, user }
