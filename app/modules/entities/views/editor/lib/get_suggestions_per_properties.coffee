{ prepareSearchResult } = require 'modules/entities/lib/search/entities_uris_results'

suggestionsPerProperties =
  'wdt:P629': (entity, index, propertyValuesCount)->
    # We can't infer a suggestion if the work being modified is the only wdt:P629 value
    if index is 0 and propertyValuesCount is 1 then return

    worksUris = entity.get 'claims.wdt:P629'
    unless worksUris? then return

    app.request 'get:entities:models', { uris: worksUris }
    .then getCommonSeries
    .then (commonSeriesUris)->
      if commonSeriesUris.length isnt 1 then return
      serieUri = commonSeriesUris[0]

      app.request 'get:entity:model', serieUri
      .then getOtherSerieWorks(worksUris)

getCommonSeries = (works)->
  seriesUris = works
    .map getSeriesUris
    # Filter-out empty results as it would make the intersection hereafter empty
    .filter _.identity
  return _.intersection seriesUris...

getSeriesUris = (work)-> work.get 'claims.wdt:P179'

getOtherSerieWorks = (worksUris)-> (serie)->
  serie.fetchPartsData()
  .then (partsData)->
    partsDataWithoutCurrentWorks = partsData.filter (part)-> part.uri not in worksUris
    return _.pluck partsDataWithoutCurrentWorks, 'uri'

module.exports = (property, model)->
  Promise.try ->
    getSuggestions = suggestionsPerProperties[property]
    unless getSuggestions? then return

    { entity } = model.collection
    index = model.collection.indexOf model
    propertyValuesCount = model.collection.length
    suggestionsPromise = getSuggestions entity, index, propertyValuesCount
    unless suggestionsPromise? then return

    suggestionsPromise
    .then (uris)->
      unless uris? then return
      app.request 'get:entities:models', { uris }
      .map prepareSearchResult
