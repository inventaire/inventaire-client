import { indexBy } from 'underscore'
import { API } from '#app/api/api'
import app from '#app/app'
import preq from '#app/lib/preq'
import { serializeItem, setItemUserData, type SerializedItemWithUserData } from '#inventory/lib/items'
import type { EntityUri } from '#server/types/entity'
import { serializeUser } from '#users/lib/users'

export async function getItemsData (editionsUris: EntityUri[]) {
  let { items, users } = await preq.get(API.items.byEntities({ ids: editionsUris }))
  users = users.map(serializeUser)
  items = items.map(serializeItem)
  const usersByIds = indexBy(users, '_id')
  return items.map(item => {
    return setItemUserData(item, usersByIds[item.owner])
  })
}

export function sortItemsByCategoryAndDistance (items: SerializedItemWithUserData[]) {
  const itemsByCategories = {
    personal: [],
    network: [],
    public: [],
    nearbyPublic: [],
    otherPublic: [],
  }
  items.forEach(item => {
    const category = getItemCategory(item)
    itemsByCategories[category] = [ ...itemsByCategories[category], item ]
  })
  Object.keys(itemsByCategories).forEach(category => {
    itemsByCategories[category] = itemsByCategories[category].sort(byDistance)
  })
  return itemsByCategories
}

function getItemCategory (item: SerializedItemWithUserData) {
  let category = item.category
  if (category === 'public') category = isNearby(item.distanceFromMainUser) ? 'nearbyPublic' : 'otherPublic'
  if (item.owner === app.user.id) category = 'personal'
  return category
}

const byDistance = (distanceA: number, distanceB: number) => distanceA - distanceB
const nearbyKmPerimeter = 50
export const isNearby = (distance: number) => distance != null && distance < nearbyKmPerimeter

export const categoriesHeaders = {
  personal: {
    label: 'in your inventory',
    customIcon: 'user',
    backgroundColor: '#eeeeee',
  },
  network: {
    label: "in your friends' and groups' inventories",
    customIcon: 'users',
    backgroundColor: '#f4f4f4',
  },
  nearbyPublic: {
    label: 'nearby',
    customIcon: 'dot-circle-o',
    backgroundColor: '#f8f8f8',
  },
  otherPublic: {
    label: 'elsewhere',
    customIcon: 'globe',
    backgroundColor: '#fcfcfc',
  },
}
