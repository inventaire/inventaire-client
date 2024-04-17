import { API } from '#app/api/api'
import assert_ from '#app/lib/assert_types'
import preq from '#app/lib/preq'
import { pluralize } from '#entities/lib/types/entities_types'

export const allowedValuesPerTypePerProperty = await preq.get(API.data.propertyValues).then(({ values }) => values)

export const propertiesWithValuesShortlists = Object.keys(allowedValuesPerTypePerProperty)

export function getPropertyValuesShortlist ({ type, property }) {
  assert_.string(type)
  return allowedValuesPerTypePerProperty[property][pluralize(type)]
}
