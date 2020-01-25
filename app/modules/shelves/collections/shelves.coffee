module.exports = Backbone.Collection.extend
  model: require '../models/shelf'
  url: -> app.API.shelves.base
  comparator: (shelf)-> -shelf.get('created')
