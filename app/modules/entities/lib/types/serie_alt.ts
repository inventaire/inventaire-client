import { pick, values, compact, uniq, without } from 'underscore'
import { authorProperties, type AuthorProperty } from '#entities/lib/properties'
import type { EntityUri, PropertyUri, SerializedEntity } from '#server/types/entity'

export function getSerieOrWorkExtendedAuthorsUris (entity: SerializedEntity, ignoredProperty?: AuthorProperty) {
  const props = (ignoredProperty ? without(authorProperties, ignoredProperty) : authorProperties) as PropertyUri[]
  const authorUris = values(pick(entity.claims, props)).flat()
  return uniq(compact(authorUris)) as EntityUri[]
}
