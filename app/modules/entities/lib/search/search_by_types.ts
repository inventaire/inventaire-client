import { API } from '#app/api/api'
import { assertStrings } from '#app/lib/assert_types'
import preq from '#app/lib/preq'
import { allSearchableTypes } from '#entities/lib/types/entities_types'
import type { SearchParams } from '#server/controllers/search/search'

export async function searchByTypes ({ search, types = allSearchableTypes, limit = 10, offset = 0, claim }: Pick<SearchParams, 'search' | 'types' | 'limit' | 'offset' | 'claim'>) {
  assertStrings(types)
  return preq.get(API.search({
    types,
    search,
    limit,
    offset,
    claim,
  }))
}

export function searchWorks ({ search, limit, offset }: Pick<SearchParams, 'search' | 'limit' | 'offset'>) {
  return searchByTypes({ types: [ 'works' ], search, limit, offset })
}

export function searchHumans ({ search, limit, offset }: Pick<SearchParams, 'search' | 'limit' | 'offset'>) {
  return searchByTypes({ types: [ 'humans' ], search, limit, offset })
}
