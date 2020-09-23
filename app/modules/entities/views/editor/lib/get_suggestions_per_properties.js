suggestionsPerProperties =
  'wdt:P50': require './suggestions/wdt_P50'
  'wdt:P123': require './suggestions/wdt_P123'
  'wdt:P629': require './suggestions/wdt_P629'

module.exports = (property, model)->
  Promise.try ->
    getSuggestions = suggestionsPerProperties[property]
    unless getSuggestions? then return

    { entity } = model.collection
    index = model.collection.indexOf model
    propertyValuesCount = model.collection.length
    return getSuggestions entity, index, propertyValuesCount
