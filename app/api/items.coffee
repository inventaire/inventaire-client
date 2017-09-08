{ base, action } = require('./endpoint')('items')

queryEndpoint = (actionName, idsLabel)-> (params)->
  { ids, limit, offset, fetchPublicItemsOnly, filter } = params
  data = {}
  if idsLabel? then data[idsLabel] = ids.join '|'
  if limit? then data.limit = limit
  if offset? then data.offset = offset
  if filter? then data.filter = filter
  return action actionName, data

module.exports =
  base: base

  byIds: queryEndpoint 'by-ids', 'ids'
  byUsers: queryEndpoint 'by-users', 'users'
  byEntities: queryEndpoint 'by-entities', 'uris'

  byUserAndEntity: (user, uri)->
    action 'by-user-and-entity', { user, uri }

  byUsernameAndEntity: (username, uri)->
    action 'by-user-and-entity', { username, uri }

  lastPublic: (limit=15, offset=0, assertImage)->
    action 'last-public',
      limit: limit
      offset: offset
      'assert-image': assertImage

  nearby: (range=50)-> action 'nearby', { range }

  inventoryView: action 'inventory-view'
