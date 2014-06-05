Item = require("../models/item")

module.exports = Items = Backbone.Collection.extend
  model: Item
  localStorage: new Backbone.LocalStorage('items')

  comparator: (item)->
    return item.get('title');

  filtered: (expr)->
    return  @filter (item)->
      return true if item.matches expr

  filterExpr: null