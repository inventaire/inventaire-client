Item = require "../models/item"

module.exports = class Items extends Backbone.Collection
  model: Item
  url: 'api/items'

  comparator: (item)->
    return item.get('created')

  filtered: (expr)->
    return  @filter (item)->
      return true if item.matches expr

      filterExpr: null