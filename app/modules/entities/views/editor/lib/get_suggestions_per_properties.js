import wdtP50 from './suggestions/wdt_P50.js'
import wdtP123 from './suggestions/wdt_P123.js'
import wdtP629 from './suggestions/wdt_P629.js'

const suggestionsPerProperties = {
  'wdt:P50': wdtP50,
  'wdt:P123': wdtP123,
  'wdt:P629': wdtP629
}

export async function getDefaultSuggestions ({ entity, property }) {
  const getSuggestions = suggestionsPerProperties[property]
  if (getSuggestions == null) return
  const uris = await getSuggestions({ entity })
  if (uris == null || uris.length === 0) return
  const entities = await app.request('get:entities:models', { uris })
  return entities.map(model => model.toJSON())
}
