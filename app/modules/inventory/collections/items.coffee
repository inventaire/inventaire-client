module.exports = Backbone.Collection.extend
  model: require "../models/item"
  url: -> app.API.items.base

  comparator: (item)-> - item.get 'created'

  byOwner: (ownerId)-> @where {owner: ownerId}

  byEntityUri: (uri)-> @where {entity: uri}

  byEntityUris: (uris)-> @filter (item)-> item.get('entity') in uris

  byUsername: (username)->
    owner = app.request 'get:userId:from:username', username
    return @where {owner: owner}