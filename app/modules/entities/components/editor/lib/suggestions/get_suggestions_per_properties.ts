import { reportError } from '#app/lib/reports'
import { getPropertyValuesShortlist } from '#entities/components/editor/lib/suggestions/property_values_shortlist'
import { getEntitiesList, type SerializedEntity } from '#entities/lib/entities'
import { authorProperties } from '#entities/lib/properties'
import type { Awaitable } from '#server/types/common'
import type { EntityUri, PropertyUri } from '#server/types/entity'
import { authorProperty } from './author_properties.ts'
import wdtP123 from './wdt_P123.ts'
import wdtP195 from './wdt_P195.ts'
import wdtP31 from './wdt_P31.ts'
import wdtP629 from './wdt_P629.ts'

export interface SuggestionsGetterParams {
  entity: SerializedEntity
  property: PropertyUri
}

const suggestionsPerAuthorProperties = Object.fromEntries(authorProperties.map(property => [ property, authorProperty ]))

const suggestionsPerProperties = {
  ...suggestionsPerAuthorProperties,
  'wdt:P123': wdtP123,
  'wdt:P195': wdtP195,
  'wdt:P629': wdtP629,
  'wdt:P31': wdtP31,
  'wdt:P437': ({ entity }) => getPropertyValuesShortlist({ property: 'wdt:P437', type: entity.type }),
  'wdt:P7937': ({ entity }) => getPropertyValuesShortlist({ property: 'wdt:P7937', type: entity.type }),
} as Record<PropertyUri, (params: SuggestionsGetterParams) => Awaitable<EntityUri[]>>

export async function getDefaultSuggestions ({ entity, property }: { entity: SerializedEntity, property: PropertyUri }) {
  const getSuggestions = suggestionsPerProperties[property]
  if (getSuggestions == null) return
  try {
    const uris = await getSuggestions({ entity, property })
    if (uris == null || uris.length === 0) return
    return getEntitiesList({ uris })
  } catch (err) {
    reportError(err)
  }
}
