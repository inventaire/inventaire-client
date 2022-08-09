import Item from '#inventory/models/item'
import { isNonEmptyArray } from '#lib/boolean_tests'
import preq from '#lib/preq'
import User from '#users/models/user'

export const getItemsData = async editionsUris => {
  const { items, users } = await preq.get(app.API.items.byEntities({ ids: editionsUris }))
  return fetchModelsSequentially(items, users)
}

export const sortItemsByCategorieAndDistance = items => {
  let itemsByCategories = {
    personal: [],
    network: [],
    public: [],
    nearbyPublic: [],
    otherPublic: []
  }
  items.forEach(item => {
    const categorie = getItemCategory(item)
    if (categorie) itemsByCategories[categorie] = [ ...itemsByCategories[categorie], item ]
  })
  Object.keys(itemsByCategories).forEach(category => {
    itemsByCategories[category] = itemsByCategories[category].sort(byDistance)
  })
  return itemsByCategories
}

const fetchModelsSequentially = async (items, users) => {
  const batch = _.clone(items)
  const itemsData = []
  const fetchAndAssignData = async () => {
    if (!isNonEmptyArray(batch)) return itemsData
    const item = batch.pop()
    const owner = users.find(user => user._id === item.owner)
    if (owner.position) {
      let [ itemModel, ownerModel ] = await Promise.all([
        new Item(item),
        new User(owner)
      ])
      const itemData = formatItemDataFromModel(itemModel)
      Object.assign(itemData, formatOwnerData(ownerModel))
      itemsData.push(itemData)
    }
    await fetchAndAssignData()
  }
  await fetchAndAssignData()
  return itemsData
}

const formatOwnerData = ownerModel => {
  const item = {}
  const ownerKeysMap = {
    picture: 'userPicture',
    username: 'username',
    itemsCategory: 'itemsCategory',
    position: 'position',
  }

  for (let key in ownerKeysMap) {
    const ownerValue = ownerModel.attributes[key]
    if (ownerValue) {
      item[key] = ownerValue
    }
  }

  // add ownerModel keys that are not model attributes
  item.distanceFromMainUser = ownerModel.distanceFromMainUser
  return item
}
const formatItemDataFromModel = itemModel => {
  // TODO: debackbonification must involve user `network`, `itemsCount`, `distanceFromMainUser`
  const item = {}
  item.id = itemModel.id
  item.markerType = 'item'

  const itemKeys = [
    'details',
    'owner',
    'transaction',
    'entity',
  ]
  for (let key of itemKeys) {
    const itemValue = itemModel.attributes[key]
    if (itemValue) {
      item[key] = itemValue
    }
  }

  item.title = itemModel.get('snapshot.entity:title')
  item.cover = itemModel.get('snapshot.entity:image')
  return item
}

const getItemCategory = item => {
  let categorie = item.itemsCategory
  if (categorie === 'public') categorie = isNearby(item.distanceFromMainUser) ? 'nearbyPublic' : 'otherPublic'
  if (item.owner === app.user.id) categorie = 'personal'
  return categorie
}

const byDistance = (distanceA, distanceB) => distanceA - distanceB
const nearbyKmPerimeter = 50
const isNearby = distance => nearbyKmPerimeter > distance

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
