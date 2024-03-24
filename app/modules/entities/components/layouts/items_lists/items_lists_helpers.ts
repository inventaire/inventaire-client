import { serializeItem, setItemUserData } from '#inventory/lib/items'
import preq from '#lib/preq'
import { serializeUser } from '#users/lib/users'
import { indexBy } from 'underscore'

export const getItemsData = async editionsUris => {
  let { items, users } = await preq.get(app.API.items.byEntities({ ids: editionsUris }))
  users = users.map(serializeUser)
  items = items.map(serializeItem)
  const usersByIds = indexBy(users, '_id')
  items.forEach(item => {
    setItemUserData(item, usersByIds[item.owner])
  })
  return items
}

export const sortItemsByCategoryAndDistance = items => {
  let itemsByCategories = {
    personal: [],
    network: [],
    public: [],
    nearbyPublic: [],
    otherPublic: []
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

const getItemCategory = item => {
  let category = item.category
  if (category === 'public') category = isNearby(item.distanceFromMainUser) ? 'nearbyPublic' : 'otherPublic'
  if (item.owner === app.user.id) category = 'personal'
  return category
}

const byDistance = (distanceA, distanceB) => distanceA - distanceB
const nearbyKmPerimeter = 50
export const isNearby = distance => distance != null && distance < nearbyKmPerimeter

export const categoriesHeaders = {
  personal: {
    label: 'in your inventory',
    customIcon: 'user',
    backgroundColor: '#eeeeee'
  },
  network: {
    label: "in your friends' and groups' inventories",
    customIcon: 'users',
    backgroundColor: '#f4f4f4'
  },
  nearbyPublic: {
    label: 'nearby',
    customIcon: 'dot-circle-o',
    backgroundColor: '#f8f8f8'
  },
  otherPublic: {
    label: 'elsewhere',
    customIcon: 'globe',
    backgroundColor: '#fcfcfc'
  }
}
