module.exports = (entity, index, propertyValuesCount)->
  # We can't infer a suggestion if the work being modified is the only wdt:P629 value
  if index is 0 and propertyValuesCount is 1 then return

  worksUris = entity.get 'claims.wdt:P629'
  unless worksUris? then return

  app.request 'get:entities:models', { uris: worksUris }
  .then (works)->
    worksSeriesData = getSeriesData works
    seriesUris = _.uniq _.pluck(worksSeriesData, 'serie')
    if seriesUris.length isnt 1 then return
    serieUri = seriesUris[0]
    lastOrdinal = getOrdinals(worksSeriesData, serieUri).slice(-1)[0]

    app.request 'get:entity:model', serieUri
    .then getOtherSerieWorks(worksUris, lastOrdinal)

getSeriesData = (works)->
  works
  .map getSerieData
  # Filter-out empty results as it would make the intersection hereafter empty
  .filter (data)-> data.serie?

getOrdinals = (worksSeriesData, serieUri)->
  worksSeriesData
  .filter (data)-> data.serie is serieUri and _.isPositiveIntegerString(data.ordinal)
  .map (data)-> parseOrdinal data.ordinal

parseOrdinal = (ordinal)->
  if _.isPositiveIntegerString ordinal then parseInt ordinal

getSerieData = (work)->
  serie = work.get 'claims.wdt:P179.0'
  ordinal = work.get 'claims.wdt:P1545.0'
  return { serie, ordinal }

getOtherSerieWorks = (worksUris, lastOrdinal)-> (serie)->
  serie.fetchPartsData()
  .then (partsData)->
    partsDataWithoutCurrentWorks = getReorderedParts partsData, worksUris, lastOrdinal
    return _.pluck partsDataWithoutCurrentWorks, 'uri'

getReorderedParts = (partsData, worksUris, lastOrdinal)->
  unless lastOrdinal?
    return partsData.filter (part)-> part.uri not in worksUris

  partsBefore = []
  partsAfter = []
  partsWithoutOrdinal = []

  for part in partsData
    if part.uri not in worksUris
      parsedOrdinal = parseOrdinal part.ordinal
      if parsedOrdinal
        if parsedOrdinal > lastOrdinal then partsAfter.push part
        else partsBefore.push part
      else
        partsWithoutOrdinal.push part

  # Return the parts directly after the current one first
  return partsAfter.concat partsBefore, partsWithoutOrdinal
