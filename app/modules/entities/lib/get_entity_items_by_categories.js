import error_ from 'lib/error'

const getAllEntityUris = model => // Make sure items are fetched for all sub entities as editions that aren't
// shown (e.g. on work_layout, editions from other language than
// the user are filtered-out by default) won't request their items
// Then 'items:getByEntities' will take care of making every request only once.
  model.fetchSubEntities()
.then(() => model.get('allUris'))

const spreadItems = uris => function (items) {
  let category
  const itemsByCategories = {
    personal: [],
    network: [],
    public: []
  }

  if (items == null) {
    _.error(error_.new('missing items collection', 500, { uris }), 'spreadItems')
    return itemsByCategories
  }

  for (const item of items.models) {
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
    const [ nearbyPublic, otherPublic ] = Array.from(_.partition(itemsByCategories.public, isNearby(nearbyKmPerimeter)))
    itemsByCategories.nearbyPublic = nearbyPublic
    itemsByCategories.otherPublic = otherPublic
  }

  return itemsByCategories
}

export default function () {
  if (this.itemsByCategory != null) { return Promise.resolve(this.itemsByCategory) }

  return getAllEntityUris(this)
  .then(uris => app.request('items:getByEntities', uris)
  .then(spreadItems(uris))).tap(itemsByCategory => { return this.itemsByCategory = itemsByCategory })
};

const byDistance = (itemA, itemB) => getItemDistance(itemA) - getItemDistance(itemB)

const isNearby = nearbyKmPerimeter => item => nearbyKmPerimeter > getItemDistance(item)

const getItemDistance = item => item.user?.kmDistanceFormMainUser || Infinity

const getPerimeter = function (nearestPublicItemDistance) {
  if (nearestPublicItemDistance < 50) {
    return Math.max((nearestPublicItemDistance * 2), 10)
  } else { return 100 }
}
