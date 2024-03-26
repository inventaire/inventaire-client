import app from '#app/app'
import { allSearchableTypes } from '#entities/lib/types/entities_types'
import assert_ from '#lib/assert_types'
import preq from '#lib/preq'

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
  return searchByTypes({ types: 'works', search, limit, offset })
}

export function searchHumans ({ search, limit, offset }) {
  return searchByTypes({ types: 'humans', search, limit, offset })
}
