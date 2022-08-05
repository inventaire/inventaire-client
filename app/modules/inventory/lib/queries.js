import log_ from '#lib/loggers'
import preq from '#lib/preq'
import { tap } from '#lib/promises'
import Item from '#inventory/models/item'
import Items from '#inventory/collections/items'
import error_ from '#lib/error'
import { indexBy } from 'underscore'
import { serializeUser } from '#users/lib/users'

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

const getUserItems = function (params) {
  const userId = params.model.id
  return makeRequest(params, 'byUsers', [ userId ])
}

const makeRequest = function (params, endpoint, ids, filter) {
  if (ids.length === 0) return { items: [], total: 0 }
  const { collection, limit, offset } = params
  return preq.get(app.API.items[endpoint]({ ids, limit, offset, filter }))
  // Use tap to return the server response instead of the collection
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

const makeRequestAlt = async (params, endpoint, ids, filter) => {
  if (ids.length === 0) return { items: [], total: 0 }
  const { limit, offset } = params
  const res = await preq.get(app.API.items[endpoint]({ ids, limit, offset, filter, includeUsers: true }))
  updateItemsParams(res, params)
  return res
}

const getByIds = async ({ ids, items }) => {
  const res = await preq.get(app.API.items.byIds({ ids, includeUsers: true }))
  updateItemsParams(res, { items })
  return res
}
const getNearbyItems = async params => {
  const { limit, offset } = params
  const res = await preq.get(app.API.items.nearby(limit, offset))
  updateItemsParams(res, params)
  return res
}

const getLastPublic = async params => {
  const { limit, offset, assertImage } = params
  const res = await preq.get(app.API.items.lastPublic(limit, offset, assertImage))
  updateItemsParams(res, params)
  return res
}

const getRecentPublic = async params => {
  const { limit, lang, assertImage } = params
  const res = await preq.get(app.API.items.recentPublic(limit, lang, assertImage))
  updateItemsParams(res, params)
  return res
}

const getNetworkItems = async params => {
  await app.request('wait:for', 'relations')
  const { network: networkIds } = app.relations
  return makeRequestAlt(params, 'byUsers', networkIds)
}

const updateItemsParams = (res, params) => {
  const { items: newItems, users } = res
  const usersById = indexBy(users.map(serializeUser), '_id')
  newItems.forEach(item => {
    item.user = usersById[item.owner]
  })
  params.items.push(...newItems)
  return res
}

export default app => app.reqres.setHandlers({
  'items:getByIds': getByIds,
  'items:getByEntities': getByEntities,
  'items:getNearbyItems': getNearbyItems,
  'items:getLastPublic': getLastPublic,
  'items:getRecentPublic': getRecentPublic,
  'items:getNetworkItems': getNetworkItems,
  'items:getUserItems': getUserItems,
  'items:getByUserIdAndEntities': getByUserIdAndEntities,

  // Using a different naming to match reqGrab requests style
  'get:item:model': getById
})
