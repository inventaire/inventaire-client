import preq from '#lib/preq'
import { pluralize } from '#entities/lib/types/entities_types'

const cache = {}

export default function (property) {
  return async ({ entity }) => {
    const type = pluralize(entity.type)
    const cacheKey = `${property}|${type}`
    if (cache[cacheKey]) {
      return cache[cacheKey]
    } else {
      const { values } = await preq.get(app.API.data.propertyValues(property, type))
      cache[cacheKey] = values
      return values
    }
  }
}
