module.exports = class Items extends Backbone.Collection
  model: require "../models/item"
  url: -> app.API.items.items

  comparator: (item)-> item.get 'created'

  byOwner: (ownerId)-> @where {owner: ownerId}

  byUsername: (username)->
    id = app.request 'getIdFromUsername', username
    return @where {owner: id}