import wdtP50 from './wdt_P50.js'
import wdtP123 from './wdt_P123.js'
import wdtP195 from './wdt_P195.js'
import wdtP629 from './wdt_P629.js'
import { reportError } from '#lib/reports'
import propertyValuesShortlist from './property_values_shortlist.js'

const suggestionsPerProperties = {
  'wdt:P50': wdtP50,
  'wdt:P123': wdtP123,
  'wdt:P195': wdtP195,
  'wdt:P629': wdtP629,
  'wdt:P31': propertyValuesShortlist('wdt:P31'),
  'wdt:P437': propertyValuesShortlist('wdt:P437'),
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
