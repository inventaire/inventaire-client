{ public:publik, authentified } = require('./endpoint')('items')

buildGetPath = (action, query={})->
  _.buildPath publik, _.extend({ action }, query)

queryEndpoint = (actionName, idsLabel)-> (ids, fetchPublicItemsOnly=false)->
  data = {}
  if idsLabel? then data[idsLabel] = ids.join '|'
  # Do not use the public endpoint to fetch public items only
  # as the main user items would return without ownerSafe attributes
  if app.user.loggedIn and fetchPublicItemsOnly then data.filter = 'public'
  return buildGetPath actionName, data

module.exports =
  authentified: authentified

  byIds: queryEndpoint 'by-ids', 'ids'
  byUsers: queryEndpoint 'by-users', 'users'
  byEntities: queryEndpoint 'by-entities', 'uris'

  byUsernameAndEntity: (username, uri)->
    buildGetPath 'by-username-and-entity', { username, uri }

  lastPublic: (limit=15, offset=0, assertImage)->
    buildGetPath 'last-public',
      limit: limit
      offset: offset
      'assert-image': assertImage

  nearby: (range=50)-> _.buildPath authentified, { action: 'nearby', range }
