import wdtP50 from './suggestions/wdt_P50'
import wdtP123 from './suggestions/wdt_P123'
import wdtP629 from './suggestions/wdt_P629'
import propertyValuesShortlist from './suggestions/property_values_shortlist'

const suggestionsPerProperties = {
  'wdt:P50': wdtP50,
  'wdt:P123': wdtP123,
  'wdt:P629': wdtP629,
  'wdt:P31': propertyValuesShortlist('wdt:P31'),
  'wdt:P437': propertyValuesShortlist('wdt:P437'),
}

export default async (property, model) => {
  const getSuggestions = suggestionsPerProperties[property]
  if (getSuggestions == null) return

  const { entity } = model.collection
  const index = model.collection.indexOf(model)
  const propertyValuesCount = model.collection.length
  return getSuggestions(entity, index, propertyValuesCount)
}
