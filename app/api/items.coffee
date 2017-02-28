{ public:publik, authentified } = require('./endpoint')('items')

buildGetPath = (action, query={})->
  _.buildPath publik, _.extend({ action }, query)

queryEndpoint = (actionName, idsLabel)-> (params)->
  { ids, limit, offset, fetchPublicItemsOnly, filter } = params
  data = {}
  if idsLabel? then data[idsLabel] = ids.join '|'
  if limit? then data.limit = limit
  if offset? then data.offset = offset
  if filter? then data.filter = filter
  return buildGetPath actionName, data

module.exports =
  authentified: authentified

  byIds: queryEndpoint 'by-ids', 'ids'
  byUsers: queryEndpoint 'by-users', 'users'
  byEntities: queryEndpoint 'by-entities', 'uris'

  byUserAndEntity: (user, uri)->
    buildGetPath 'by-user-and-entity', { user, uri }

  byUsernameAndEntity: (username, uri)->
    buildGetPath 'by-user-and-entity', { username, uri }

  lastPublic: (limit=15, offset=0, assertImage)->
    buildGetPath 'last-public',
      limit: limit
      offset: offset
      'assert-image': assertImage

  nearby: (range=50)-> _.buildPath authentified, { action: 'nearby', range }
