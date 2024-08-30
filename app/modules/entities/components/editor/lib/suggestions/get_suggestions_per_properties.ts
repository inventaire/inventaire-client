import app from '#app/app'
import { reportError } from '#app/lib/reports'
import { authorProperties } from '#app/modules/entities/lib/properties'
import { getPropertyValuesShortlist } from '#entities/components/editor/lib/suggestions/property_values_shortlist'
import { authorProperty } from './author_properties.ts'
import wdtP123 from './wdt_P123.ts'
import wdtP195 from './wdt_P195.ts'
import wdtP629 from './wdt_P629.ts'

const suggestionsPerAuthorProperties = Object.fromEntries(authorProperties.map(property => [ property, authorProperty ]))

const suggestionsPerProperties = {
  ...suggestionsPerAuthorProperties,
  'wdt:P123': wdtP123,
  'wdt:P195': wdtP195,
  'wdt:P629': wdtP629,
  'wdt:P31': ({ entity }) => getPropertyValuesShortlist({ property: 'wdt:P31', type: entity.type }),
  'wdt:P437': ({ entity }) => getPropertyValuesShortlist({ property: 'wdt:P437', type: entity.type }),
}

export async function getDefaultSuggestions ({ entity, property }) {
  const getSuggestions = suggestionsPerProperties[property]
  if (getSuggestions == null) return
  try {
    const uris = await getSuggestions({ entity })
    if (uris == null || uris.length === 0) return
    const entities = await app.request('get:entities:models', { uris })
    return entities.map(model => model.toJSON())
  } catch (err) {
    reportError(err)
  }
}
