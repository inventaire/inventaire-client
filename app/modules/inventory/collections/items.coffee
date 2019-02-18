module.exports = Backbone.Collection.extend
  model: require '../models/item'
  comparator: (item)-> -item.get('created')
