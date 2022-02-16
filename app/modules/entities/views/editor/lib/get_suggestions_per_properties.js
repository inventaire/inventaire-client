import wdtP50 from './suggestions/wdt_P50.js'
import wdtP123 from './suggestions/wdt_P123.js'
import wdtP629 from './suggestions/wdt_P629.js'

const suggestionsPerProperties = {
  'wdt:P50': wdtP50,
  'wdt:P123': wdtP123,
  'wdt:P629': wdtP629
}

export default async (property, model) => {
  const getSuggestions = suggestionsPerProperties[property]
  if (getSuggestions == null) return

  const { entity } = model.collection
  const index = model.collection.indexOf(model)
  const propertyValuesCount = model.collection.length
  return getSuggestions(entity, index, propertyValuesCount)
}
