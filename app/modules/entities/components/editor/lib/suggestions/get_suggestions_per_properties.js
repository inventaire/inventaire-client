import wdtP50 from './wdt_P50.js'
import wdtP123 from './wdt_P123.js'
import wdtP195 from './wdt_P195.js'
import wdtP629 from './wdt_P629.js'

const suggestionsPerProperties = {
  'wdt:P50': wdtP50,
  'wdt:P123': wdtP123,
  'wdt:P195': wdtP195,
  'wdt:P629': wdtP629,
}

export async function getDefaultSuggestions ({ entity, property }) {
  const getSuggestions = suggestionsPerProperties[property]
  if (getSuggestions == null) return
  const uris = await getSuggestions({ entity })
  if (uris == null || uris.length === 0) return
  const entities = await app.request('get:entities:models', { uris })
  return entities.map(model => model.toJSON())
}
