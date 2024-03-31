import { isArray, flatten, indexBy } from 'underscore'
import app from '#app/app'
import Items from '#inventory/collections/items'
import Item from '#inventory/models/item'
import { newError } from '#lib/error'
import log_ from '#lib/loggers'
import preq from '#lib/preq'
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
    throw newError('not found', 404, id)
  }
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
  if (!isArray(items)) items = flatten(Object.values(items))

  if (users?.length > 0) app.execute('users:add', users)

  // If no collection is passed, let the consumer deal with the results
  if (collection == null) return

  if (items?.length > 0) collection.add(items)

  return collection
}

const makeRequestAlt = async (params, endpoint, ids, filter?) => {
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

export async function getUserItems (params) {
  const { userId } = params
  return makeRequestAlt(params, 'byUsers', [ userId ])
}

const getNetworkItems = async params => {
  await app.request('wait:for', 'relations')
  const { network: networkIds } = app.relations
  return makeRequestAlt(params, 'byUsers', networkIds)
}

const updateItemsParams = (res, params) => {
  const { items: newItems, continue: continu, total } = res
  params.hasMore = continu != null
  params.total = total
  addItemsUsers(res)
  params.items.push(...newItems)
  return res
}

export const addItemsUsers = ({ items, users }) => {
  const usersById = indexBy(users.map(serializeUser), '_id')
  items.forEach(item => {
    item.user = usersById[item.owner]
  })
}

export default app => app.reqres.setHandlers({
  'items:getByIds': getByIds,
  'items:getByEntities': getByEntities,
  'items:getNearbyItems': getNearbyItems,
  'items:getLastPublic': getLastPublic,
  'items:getRecentPublic': getRecentPublic,
  'items:getNetworkItems': getNetworkItems,
  'items:getByUserIdAndEntities': getByUserIdAndEntities,

  // Using a different naming to match reqGrab requests style
  'get:item:model': getById,
})
