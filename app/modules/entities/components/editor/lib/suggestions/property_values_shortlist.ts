import { API } from '#app/api/api'
import { assertString } from '#app/lib/assert_types'
import preq from '#app/lib/preq'
import { pluralize } from '#entities/lib/types/entities_types'
import type { EntityUri } from '#server/types/entity'

export const allowedValuesPerTypePerProperty = await preq.get(API.data.propertyValues).then(({ values }) => values)

export const propertiesWithValuesShortlists = Object.keys(allowedValuesPerTypePerProperty)

export function getPropertyValuesShortlist ({ type, property }) {
  assertString(type)
  return allowedValuesPerTypePerProperty[property][pluralize(type)] as EntityUri[]
}
