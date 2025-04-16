import { indexBy } from 'underscore'
import { API } from '#app/api/api'
import preq from '#app/lib/preq'
import { getRelations } from '#modules/users/lib/relations'
import type { EntityUri } from '#server/types/entity'
import type { UserId } from '#server/types/user'
import { serializeUser } from '#users/lib/users'
import { serializeItem, setItemUserData, type SerializedItemWithUserData } from './items'

export async function getItemsByUserIdAndEntities (userId: UserId, uris: EntityUri | EntityUri[]) {
  const { items, users } = await preq.get(API.items.byUserAndEntities(userId, uris, true))
  const serializedUsers = users.map(serializeUser)
  const serializedItems = items.map(serializeItem)
  const usersByIds = indexBy(serializedUsers, '_id')
  return serializedItems.map(item => {
    return setItemUserData(item, usersByIds[item.owner])
  }) as SerializedItemWithUserData[]
}

async function makeRequestAlt (params, endpoint, ids, filter?) {
  if (ids.length === 0) return { items: [], total: 0 }
  const { limit, offset } = params
  const res = await preq.get(API.items[endpoint]({ ids, limit, offset, filter, includeUsers: true }))
  updateItemsParams(res, params)
  return res
}

export async function getItemsByIds ({ ids, items }) {
  const res = await preq.get(API.items.byIds({ ids, includeUsers: true }))
  updateItemsParams(res, { items })
  return res
}

export async function getNearbyItems (params) {
  const { limit, offset } = params
  const res = await preq.get(API.items.nearby(limit, offset))
  updateItemsParams(res, params)
  return res
}

export async function getRecentPublicItems (params) {
  const { limit, lang, assertImage } = params
  const res = await preq.get(API.items.recentPublic(limit, lang, assertImage))
  updateItemsParams(res, params)
  return res
}

export async function getItemsByBbox (params) {
  const { bbox, limit, lang } = params
  const res = await preq.get(API.items.byBbox(bbox, limit, lang))
  updateItemsParams(res, params)
  return res
}

export async function getUserItems (params) {
  const { userId } = params
  return makeRequestAlt(params, 'byUsers', [ userId ])
}

export async function getNetworkItems (params) {
  const { network: networkIds } = await getRelations()
  return makeRequestAlt(params, 'byUsers', networkIds)
}

function updateItemsParams (res, params) {
  const { items: newItems, continue: continu, total } = res
  params.hasMore = continu != null
  params.total = total
  addItemsUsers(res)
  params.items.push(...newItems)
  return res
}

export function addItemsUsers ({ items, users }) {
  const usersById = indexBy(users.map(serializeUser), '_id')
  items.forEach(item => {
    item.user = usersById[item.owner]
  })
}
