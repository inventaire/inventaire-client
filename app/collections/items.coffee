module.exports = class Items extends Backbone.Collection
  model: require "../models/item"
  url: 'api/items'

  comparator: (item)->
    return item.get('created')