import { partition } from 'underscore'
import app from '#app/app'
import { newError } from '#app/lib/error'
import log_ from '#app/lib/loggers'

// Make sure items are fetched for all sub entities as editions that aren't
// shown (e.g. on work_layout, editions from other language than
// the user are filtered-out by default) won't request their items
// Then 'items:getByEntities' will take care of making every request only once.
const getAllEntityUris = model => {
  return model.fetchSubEntities().then(() => model.get('allUris'))
}

interface ItemsByCategories {
  personal: unknown[]
  network: unknown[]
  public: unknown[]
  nearbyPublic?: unknown[]
  otherPublic?: unknown[]
}

const spreadItems = uris => async items => {
  let category
  const itemsByCategories: ItemsByCategories = {
    personal: [],
    network: [],
    public: [],
  }

  if (items == null) {
    log_.error(newError('missing items collection', 500, { uris }), 'spreadItems')
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

  if (app.user.has('position')) {
    if (itemsByCategories.public.length > 0) {
      const nearestPublicItem = itemsByCategories.public[0]
      const nearestPublicItemDistance = getItemDistance(nearestPublicItem)
      const nearbyKmPerimeter = getPerimeter(nearestPublicItemDistance)
      const [ nearbyPublic, otherPublic ] = partition(itemsByCategories.public, isNearby(nearbyKmPerimeter))
      itemsByCategories.nearbyPublic = nearbyPublic
      itemsByCategories.otherPublic = otherPublic
    } else {
      itemsByCategories.nearbyPublic = []
      itemsByCategories.otherPublic = []
    }
  }

  return itemsByCategories
}

export default async function () {
  if (this.itemsByCategory != null) return this.itemsByCategory

  const uris = await getAllEntityUris(this)
  this.itemsByCategory = await app.request('items:getByEntities', uris).then(spreadItems(uris))
  return this.itemsByCategory
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
