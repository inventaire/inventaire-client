import { isNonEmptyArray } from '#lib/boolean_tests'
import Item from '#inventory/models/item'
import User from '#users/models/user'
import preq from '#lib/preq'

export const getItemsData = async uris => {
  const { items, users } = await preq.get(app.API.items.byEntities({ ids: uris }))
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
  // intention is to gather all necessary data in one object (including values defined in backbone models) which is not a backbone model,
  // TODO: debackbonification must involve user `network`, `itemsCount`, `distanceFromMainUser`
  const item = {}
  item.id = itemModel.id

  const itemKeys = [
    'details',
    'owner',
    'transaction',
  ]
  for (let key of itemKeys) {
    const itemValue = itemModel.attributes[key]
    if (itemValue) {
      item[key] = itemValue
    }
  }

  const snapshot = itemModel.get('snapshot')
  const cover = snapshot['entity:image']
  item.cover = cover
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
