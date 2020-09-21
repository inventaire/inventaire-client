InventoryLayout = require '../inventory/views/inventory_layout'
ShelfModel = require './models/shelf'
{ getById } = require './lib/shelves'
error_ = require 'lib/error'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'shelves(/)(:id)(/)': 'showShelfFromId'
        # Redirection
        'shelf(/)(:id)(/)': 'showShelfFromId'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    app.commands.setHandlers
      'show:shelf': showShelf

API =
  showShelfFromId: (shelfId)->
    unless shelfId? then return app.execute 'show:inventory:main:user'

    getById(shelfId)
    .then (shelf)->
      if shelf?
        model = new ShelfModel shelf
        showShelfFromModel model
      else
        throw error_.new 'not found', 404, { shelfId }
    .catch app.Execute('show:error')

showShelf = (shelf)->
  if _.isShelfId shelf then API.showShelfFromId shelf
  else showShelfFromModel shelf

showShelfFromModel = (shelf)->
  owner = shelf.get('owner')
  # Passing shelf to display items and passing owner for user profile info
  app.layout.main.show new InventoryLayout {
    shelf,
    user: owner
    standalone: true
  }
  app.navigateFromModel shelf
