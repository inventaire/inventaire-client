import preq from '#lib/preq'
import { allSearchableTypes } from '#entities/lib/types/entities_types'

export default function (types) {
  types = types || allSearchableTypes
  return async function (search, limit, offset) {
    return preq.get(app.API.search({
      types,
      search,
      limit,
      offset,
    }))
  }
}
