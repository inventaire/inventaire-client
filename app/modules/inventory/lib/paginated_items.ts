import type { ContextualizedError } from '#app/lib/error'
import log_ from '#app/lib/loggers'
import type { Item } from '#server/types/item'
import type { ItemsPageRequestFn } from './queries'

interface Pagination {
  items: Item[]
  limit: number
  offset?: number
  allowMore: boolean
  moreData?: { status: boolean, total?: number, continue?: number }
  hasMore?: () => boolean
  fetchMore?: () => Promise<void>
}

interface GetPaginationParametersParams {
  allowMore: boolean
  request: ItemsPageRequestFn
  limit: number
}
export function getPaginationParameters (params: GetPaginationParametersParams) {
  const { allowMore, request, limit } = params
  const pagination: Pagination = {
    items: [] as Item[],
    limit,
    allowMore,
  }
  pagination.moreData = { status: true }
  pagination.hasMore = () => pagination.moreData.status
  pagination.fetchMore = FetchMore(request, pagination)
  return pagination
}

function FetchMore (request: ItemsPageRequestFn, pagination: Pagination) {
  const { items, moreData } = pagination
  // Avoiding fetching more items several times at a time
  // as it will just return the same items, given that it will pass
  // the same arguments.
  // Known case: when the view is locked on the infiniteScroll trigger
  let busy = false
  async function fetchMore () {
    const done = (moreData.total != null) && (items.length >= moreData.total)
    if (busy || done) return

    busy = true
    pagination.offset = items.length
    try {
      const res = await request({
        items: pagination.items,
        limit: pagination.limit,
        offset: pagination.offset,
      })
      moreData.total = res.total
      moreData.continue = res.continue
    } catch (err) {
      catch404(err)
    } finally {
      busy = false
    }
  }

  function catch404 (err: ContextualizedError) {
    if (err.statusCode === 404) {
      moreData.status = false
      log_.warn('no more items to show')
    } else {
      throw err
    }
  }

  return fetchMore
}
