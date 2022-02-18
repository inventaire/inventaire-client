import log_ from '#lib/loggers'
import Items from '#modules/inventory/collections/items'
import ItemsCascade from '#modules/inventory/views/items_cascade'

export default async params => {
  let collection, moreData
  const { layout, regionName, allowMore, showDistance } = params
  params.collection = collection = new Items()

  // Use an object to store the flag so that it can be modified
  // by functions the object is passed to
  params.moreData = moreData = { status: true }
  const hasMore = () => moreData.status
  const fetchMore = FetchMore(params)

  await fetchMore()
  layout.showChildView(regionName, new ItemsCascade({
    collection,
    // if not allowMore, let ItemsList set the default values
    fetchMore: allowMore ? fetchMore : undefined,
    hasMore: allowMore ? hasMore : undefined,
    showDistance
  }))
}

const FetchMore = function (params) {
  const { request, collection, moreData, fallback } = params
  // Avoiding fetching more items several times at a time
  // as it will just return the same items, given that it will pass
  // the same arguments.
  // Known case: when the view is locked on the infiniteScroll trigger
  let busy = false
  const fetchMore = async () => {
    const done = (moreData.total != null) && (collection.length >= moreData.total)
    if (busy || done) return

    busy = true
    params.offset = collection.length
    return app.request(request, params)
    .then(res => {
      moreData.total = res.total
      moreData.continue = res.continue
      // Display the inventory welcome screen when appropriate
      if (res.total === 0 && fallback != null) return fallback()
    })
    .catch(catch404(fallback))
    .finally(() => { busy = false })
  }

  const catch404 = fallback => err => {
    if (err.statusCode === 404) {
      moreData.status = false
      log_.warn('no more items to show')
      if (fallback != null) return fallback()
    } else {
      throw err
    }
  }

  return fetchMore
}
