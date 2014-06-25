Item = require "../models/item"

module.exports = Items = Backbone.Collection.extend
  model: Item
  url: ->
    "username/items"
  # parse: (res)->
  #   console.log "PARSING"
  #   console.log res.responseJSON
  #   return res.responseJSON

  comparator: (item)->
    return item.get('title');

  filtered: (expr)->
    return  @filter (item)->
      return true if item.matches expr

  filterExpr: null