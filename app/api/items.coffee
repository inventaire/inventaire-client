{ base, action } = require('./endpoint')('items')
{ buildPath } = require 'lib/location'

queryEndpoint = (actionName, idsLabel)-> (params)->
  { ids, limit, offset, fetchPublicItemsOnly, filter, includeUsers } = params
  data = {}
  if idsLabel? then data[idsLabel] = _.forceArray(ids).join '|'
  if limit? then data.limit = limit
  if offset? then data.offset = offset
  if filter? then data.filter = filter
  if includeUsers? then data['include-users'] = includeUsers
  return action actionName, data

module.exports =
  base: base
  update: action 'bulk-update'
  delete: (id)-> buildPath base, { id }

  byIds: queryEndpoint 'by-ids', 'ids'
  byUsers: queryEndpoint 'by-users', 'users'
  byEntities: queryEndpoint 'by-entities', 'uris'

  byUserAndEntity: (user, uri)->
    action 'by-user-and-entity', { user, uri }

  lastPublic: (limit = 15, offset = 0, assertImage)->
    action 'last-public', { limit, offset, 'assert-image': assertImage }

  recentPublic: (limit = 15, lang, assertImage)->
    action 'recent-public', { limit, lang, 'assert-image': assertImage }

  nearby: (limit, offset, range = 50)-> action 'nearby', { limit, offset, range }

  inventoryView: (params)-> action 'inventory-view', params

  deleteByIds: action 'delete-by-ids'
