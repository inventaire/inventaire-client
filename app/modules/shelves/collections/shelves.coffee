ShelfModel = require '../models/shelf'

module.exports = Backbone.Collection.extend
  model: ShelfModel
  url: -> app.API.shelves.base
  comparator: (shelf)-> -shelf.get('created')
