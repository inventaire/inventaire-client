import preq from '#lib/preq'
import { allSearchableTypes } from '#entities/lib/types/entities_types'

export async function searchByTypes ({ search, types = allSearchableTypes, limit = 10, offset = 0 }) {
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
