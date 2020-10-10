import log_ from 'lib/loggers'
import error_ from 'lib/error'

// Make sure items are fetched for all sub entities as editions that aren't
// shown (e.g. on work_layout, editions from other language than
// the user are filtered-out by default) won't request their items
// Then 'items:getByEntities' will take care of making every request only once.
const getAllEntityUris = model => {
  return model.fetchSubEntities().then(() => model.get('allUris'))
}

const spreadItems = uris => async items => {
  let category
  const itemsByCategories = {
    personal: [],
    network: [],
    public: []
  }

  if (items == null) {
    log_.error(error_.new('missing items collection', 500, { uris }), 'spreadItems')
    return itemsByCategories
  }
  for (const item of items.models) {
    if (!item.user) await item.waitForUser
    category = item.user.get('itemsCategory')
    itemsByCategories[category].push(item)
  }

  for (category in itemsByCategories) {
    const categoryItems = itemsByCategories[category]
    categoryItems.sort(byDistance)
  }

  if (app.user.has('position') && (itemsByCategories.public.length > 0)) {
    const nearestPublicItem = itemsByCategories.public[0]
    const nearestPublicItemDistance = getItemDistance(nearestPublicItem)
    const nearbyKmPerimeter = getPerimeter(nearestPublicItemDistance)
    const [ nearbyPublic, otherPublic ] = _.partition(itemsByCategories.public, isNearby(nearbyKmPerimeter))
    itemsByCategories.nearbyPublic = nearbyPublic
    itemsByCategories.otherPublic = otherPublic
  }

  return itemsByCategories
}

export default async function () {
  if (this.itemsByCategory != null) return this.itemsByCategory

  const uris = await getAllEntityUris(this)
  const itemsByCategory = await app.request('items:getByEntities', uris).then(spreadItems(uris))
  this.itemsByCategory = itemsByCategory
  return itemsByCategory
}

const byDistance = (itemA, itemB) => getItemDistance(itemA) - getItemDistance(itemB)

const isNearby = nearbyKmPerimeter => item => nearbyKmPerimeter > getItemDistance(item)

const getItemDistance = item => item.user?.kmDistanceFormMainUser || Infinity

const getPerimeter = function (nearestPublicItemDistance) {
  if (nearestPublicItemDistance < 50) {
    return Math.max((nearestPublicItemDistance * 2), 10)
  } else {
    return 100
  }
}
