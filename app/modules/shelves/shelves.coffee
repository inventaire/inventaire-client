InventoryLayout = require '../inventory/views/inventory_layout'
ShelfModel = require './models/shelf'
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
  showShelf: (shelfId, shelf)->
    Promise.try -> if shelfId then getById(shelfId) else shelf
    .then (shelf)->
      if shelf? then new ShelfModel shelf
      else throw error_.new 'not found', 404, { shelfId }
    .then showShelfInventoryLayout

showShelfInventoryLayout = (shelf)->
  owner = shelf.get('owner')
  if app.request 'require:loggedIn', 'shelves'
    # Passing shelf to display items and passing owner for user profile info
    app.layout.main.show new InventoryLayout { shelf, user: owner }
