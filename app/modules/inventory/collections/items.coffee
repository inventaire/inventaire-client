module.exports = Backbone.Collection.extend
  model: require '../models/item'
  url: -> app.API.items.base
  comparator: (item)-> -item.get('created')
