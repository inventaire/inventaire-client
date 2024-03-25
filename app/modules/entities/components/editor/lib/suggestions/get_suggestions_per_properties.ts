import { getPropertyValuesShortlist } from '#entities/components/editor/lib/suggestions/property_values_shortlist'
import { reportError } from '#lib/reports'
import wdtP123 from './wdt_P123.ts'
import wdtP195 from './wdt_P195.ts'
import wdtP50 from './wdt_P50.ts'
import wdtP629 from './wdt_P629.ts'

const suggestionsPerProperties = {
  'wdt:P50': wdtP50,
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
