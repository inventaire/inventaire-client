import log_ from '#lib/loggers'
import preq from '#lib/preq'
import { tap } from '#lib/promises'
import Item from '#modules/inventory/models/item'
import Items from '#modules/inventory/collections/items'
import getEntitiesItemsCount from './get_entities_items_count'
import error_ from '#lib/error'

const getById = async id => {
  const ids = [ id ]

  const { items, users } = await preq.get(app.API.items.byIds({ ids, includeUsers: true }))
    .catch(log_.ErrorRethrow('findItemById err'))

  const item = items[0]

  if (item != null) {
    app.execute('users:add', users)
    return new Item(item)
  } else {
    throw error_.new('not found', 404, id)
  }
}

const getByIds = async ids => {
  const { items } = await preq.get(app.API.items.byIds({ ids }))
  return items.map(item => new Item(item))
}

const getNetworkItems = async params => {
  await app.request('wait:for', 'relations')
  const { network: networkIds } = app.relations
  return makeRequest(params, 'byUsers', networkIds)
}

const getUserItems = function (params) {
  const userId = params.model.id
  return makeRequest(params, 'byUsers', [ userId ])
}

const getGroupItems = params => makeRequest(params, 'byUsers', params.model.allMembersIds(), 'group')

const makeRequest = function (params, endpoint, ids, filter) {
  if (ids.length === 0) return { items: [], total: 0 }
  const { collection, limit, offset } = params
  return preq.get(app.API.items[endpoint]({ ids, limit, offset, filter }))
  // Use tap to return the server response instead of the collection
  .then(tap(addItemsAndUsers(collection)))
}

const getNearbyItems = function (params) {
  const { collection, limit, offset } = params
  return preq.get(app.API.items.nearby(limit, offset))
  .then(tap(addItemsAndUsers(collection)))
}

const getLastPublic = function (params) {
  const { collection, limit, offset, assertImage } = params
  return preq.get(app.API.items.lastPublic(limit, offset, assertImage))
  .then(tap(addItemsAndUsers(collection)))
}

const getRecentPublic = function (params) {
  const { collection, limit, lang, assertImage } = params
  return preq.get(app.API.items.recentPublic(limit, lang, assertImage))
  .then(tap(addItemsAndUsers(collection)))
}

const getItemByQueryUrl = function (queryUrl) {
  const collection = new Items()
  return preq.get(queryUrl)
  .then(addItemsAndUsers(collection))
}

const getByEntities = uris => getItemByQueryUrl(app.API.items.byEntities({ ids: uris }))

const getByUserIdAndEntities = (userId, uris) => getItemByQueryUrl(app.API.items.byUserAndEntities(userId, uris))

const addItemsAndUsers = collection => function (res) {
  let { items, users } = res
  // Also accepts items indexed by listings: user, network, public
  if (!_.isArray(items)) items = _.flatten(_.values(items))

  if (users?.length > 0) app.execute('users:add', users)

  // If no collection is passed, let the consumer deal with the results
  if (collection == null) return

  if (items?.length > 0) collection.add(items)

  return collection
}

export default app => app.reqres.setHandlers({
  'items:getByIds': getByIds,
  'items:getByEntities': getByEntities,
  'items:getNearbyItems': getNearbyItems,
  'items:getLastPublic': getLastPublic,
  'items:getRecentPublic': getRecentPublic,
  'items:getNetworkItems': getNetworkItems,
  'items:getUserItems': getUserItems,
  'items:getGroupItems': getGroupItems,
  'items:getByUserIdAndEntities': getByUserIdAndEntities,
  'items:getEntitiesItemsCount': getEntitiesItemsCount,

  // Using a different naming to match reqGrab requests style
  'get:item:model': getById
})
