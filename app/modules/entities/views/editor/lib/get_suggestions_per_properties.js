// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
const suggestionsPerProperties = {
  'wdt:P50': require('./suggestions/wdt_P50'),
  'wdt:P123': require('./suggestions/wdt_P123'),
  'wdt:P629': require('./suggestions/wdt_P629')
}

export default (property, model) => Promise.try(() => {
  const getSuggestions = suggestionsPerProperties[property]
  if (getSuggestions == null) { return }

  const { entity } = model.collection
  const index = model.collection.indexOf(model)
  const propertyValuesCount = model.collection.length
  return getSuggestions(entity, index, propertyValuesCount)
})
