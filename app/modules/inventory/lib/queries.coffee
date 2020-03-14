Item = require 'modules/inventory/models/item'
Items = require 'modules/inventory/collections/items'
error_ = require 'lib/error'

getById = (id)->
  ids = [ id ]
  _.preq.get app.API.items.byIds({ ids, includeUsers: true })
  .then (res)->
    { items, users } = res
    item = items[0]
    if item?
      app.execute 'users:add', users
      return new Item(item)
    else
      throw error_.new 'not found', 404, id
  # Maybe the item was deleted or its visibility changed?
  .catch _.ErrorRethrow('findItemById err')

getByIds = (ids)->
  _.preq.get app.API.items.byIds({ ids })
  .then (res)->
    { items } = res
    return items.map (item)-> new Item item

getNetworkItems = (params)->
  app.request 'wait:for', 'relations'
  .then ->
    networkIds = app.relations.network
    makeRequest params, 'byUsers', networkIds

getUserItems = (params)->
  userId = params.model.id
  makeRequest params, 'byUsers', [ userId ]

getGroupItems = (params)->
  makeRequest params, 'byUsers', params.model.allMembersIds(), 'group'

makeRequest = (params, endpoint, ids, filter)->
  if ids.length is 0 then return { items: [], total: 0 }
  { collection, limit, offset } = params
  _.preq.get app.API.items[endpoint]({ ids, limit, offset, filter })
  # Use tap to return the server response instead of the collection
  .tap addItemsAndUsers(collection)

getNearbyItems = (params)->
  { collection, limit, offset } = params
  _.preq.get app.API.items.nearby(limit, offset)
  .tap addItemsAndUsers(collection)

getLastPublic = (params)->
  { collection, limit, offset, assertImage } = params
  _.preq.get app.API.items.lastPublic(limit, offset, assertImage)
  .tap addItemsAndUsers(collection)

getRecentPublic = (params)->
  { collection, limit, lang, assertImage } = params
  _.preq.get app.API.items.recentPublic(limit, lang, assertImage)
  .tap addItemsAndUsers(collection)

getItemByQueryUrl = (queryUrl)->
  collection = new Items
  _.preq.get queryUrl
  .then addItemsAndUsers(collection)

getByEntities = (uris)->
  getItemByQueryUrl app.API.items.byEntities({ ids: uris })

getByUserIdAndEntities = (userId, uris)->
  getItemByQueryUrl app.API.items.byUserAndEntities(userId, uris)

getInstancesCount = (userId, uris)->
  # Split in batches for cases where there might be too many uris
  # to put in a URL querystring without risking to reach URL character limit
  # Known case: when /add/import gets to import very large collections
  # The alternative would be to convert the endpoint to a POST verb to pass those uris in a body
  urisBatches = _.chunk _.uniq(uris).sort(), 50
  Promise.all urisBatches.map(getInstancesCountBatch(userId))
  .then countInstances

getInstancesCountBatch = (userId)-> (uris)->
  _.preq.get app.API.items.byUserAndEntities(userId, uris)

countInstances = (responses)->
  counts = {}
  for res in responses
    for item in res.items
      uri = item.entity
      counts[uri] ?= 0
      counts[uri]++
  return counts

addItemsAndUsers = (collection)-> (res)->
  { items, users } = res
  # Also accepts items indexed by listings: user, network, public
  unless _.isArray items then items = _.flatten _.values(items)
  unless items?.length > 0 then return collection

  if users? then app.execute 'users:add', users
  collection.add items
  return collection

module.exports = (app)->
  app.reqres.setHandlers
    'items:getByIds': getByIds
    'items:getByEntities': getByEntities
    'items:getNearbyItems': getNearbyItems
    'items:getLastPublic': getLastPublic
    'items:getRecentPublic': getRecentPublic
    'items:getNetworkItems': getNetworkItems
    'items:getUserItems': getUserItems
    'items:getGroupItems': getGroupItems
    'items:getByUserIdAndEntities': getByUserIdAndEntities
    'items:getInstancesCount': getInstancesCount

    # Using a different naming to match reqGrab requests style
    'get:item:model': getById
