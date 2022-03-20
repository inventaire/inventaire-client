import preq from '#lib/preq'
import { entityTypeNameByType } from '#entities/lib/properties'
const allSearchableTypes = Object.keys(entityTypeNameByType)

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
