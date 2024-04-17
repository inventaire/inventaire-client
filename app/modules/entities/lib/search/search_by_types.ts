import app from '#app/app'
import assert_ from '#app/lib/assert_types'
import preq from '#app/lib/preq'
import { allSearchableTypes } from '#entities/lib/types/entities_types'

export async function searchByTypes ({ search, types = allSearchableTypes, limit = 10, offset = 0 }) {
  assert_.strings(types)
  return preq.get(app.API.search({
    types,
    search,
    limit,
    offset,
  }))
}

export function searchWorks ({ search, limit, offset }) {
  return searchByTypes({ types: [ 'works' ], search, limit, offset })
}

export function searchHumans ({ search, limit, offset }) {
  return searchByTypes({ types: [ 'humans' ], search, limit, offset })
}
