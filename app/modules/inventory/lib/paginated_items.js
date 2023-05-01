import log_ from '#lib/loggers'

export function getPaginationParameters (params) {
  const { allowMore, requestName, limit, requestParams } = params
  const pagination = {
    items: [],
    limit,
    allowMore,
  }
  pagination.moreData = { status: true }
  pagination.hasMore = () => pagination.moreData.status
  pagination.fetchMore = FetchMore({ requestName, requestParams, pagination })
  return pagination
}

const FetchMore = function ({ requestName, requestParams, pagination }) {
  const { items, moreData, fallback } = pagination
  // Avoiding fetching more items several times at a time
  // as it will just return the same items, given that it will pass
  // the same arguments.
  // Known case: when the view is locked on the infiniteScroll trigger
  let busy = false
  const fetchMore = async () => {
    const done = (moreData.total != null) && (items.length >= moreData.total)
    if (busy || done) return

    busy = true
    pagination.offset = items.length
    try {
      const res = await app.request(requestName, {
        items: pagination.items,
        limit: pagination.limit,
        offset: pagination.offset,
        ...requestParams
      })
      moreData.total = res.total
      moreData.continue = res.continue
      // Display the inventory welcome screen when appropriate
      if (res.total === 0 && fallback != null) return fallback()
    } catch (err) {
      catch404(err, fallback)
    } finally {
      busy = false
    }
  }

  const catch404 = (err, fallback) => {
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
