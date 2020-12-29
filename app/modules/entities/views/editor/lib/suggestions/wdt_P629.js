import { isPositiveIntegerString } from 'lib/boolean_tests'
export default function (entity, index, propertyValuesCount) {
  // We can't infer a suggestion if the work being modified is the only wdt:P629 value
  if ((index === 0) && (propertyValuesCount === 1)) return

  const worksUris = entity.get('claims.wdt:P629')
  if (worksUris == null) return

  return app.request('get:entities:models', { uris: worksUris })
  .then(works => {
    const data = works.reduce(aggregate, { authors: [], series: [] })
    const commonAuthors = _.intersection(...data.authors)
    const commonSeries = _.intersection(...data.series)

    if (commonSeries.length === 1) {
      return getSuggestionsFromSerie(commonSeries[0], works, worksUris)
    }

    if (commonAuthors.length === 1) {
      return getSuggestionsFromAuthor(commonAuthors[0], works, worksUris)
    }
  })
}

const aggregate = function (data, work) {
  const authors = work.getExtendedAuthorsUris()
  const series = work.get('claims.wdt:P179')
  data.authors.push(authors)
  data.series.push(series)
  return data
}

const getSuggestionsFromSerie = function (serieUri, works, worksUris) {
  const worksSeriesData = getSeriesData(works)
  const lastOrdinal = getOrdinals(worksSeriesData, serieUri).slice(-1)[0]

  return app.request('get:entity:model', serieUri)
  .then(getOtherSerieWorks(worksUris, lastOrdinal))
}

const getSuggestionsFromAuthor = async (authorUri, works, worksUris) => {
  const author = await app.request('get:entity:model', authorUri)
  const { works: authorWorksData } = await author.fetchWorksData()
  return _.pluck(authorWorksData, 'uri')
  .filter(uri => !worksUris.includes(uri))
}

const getSeriesData = works => {
  return works
  .map(getSerieData)
  // Filter-out empty results as it would make the intersection hereafter empty
  .filter(data => data.serie != null)
}

const getOrdinals = (worksSeriesData, serieUri) => {
  return worksSeriesData
  .filter(data => (data.serie === serieUri) && isPositiveIntegerString(data.ordinal))
  .map(data => parseOrdinal(data.ordinal))
}

const parseOrdinal = function (ordinal) {
  if (isPositiveIntegerString(ordinal)) return parseInt(ordinal)
}

const getSerieData = function (work) {
  const serie = work.get('claims.wdt:P179.0')
  const ordinal = work.get('claims.wdt:P1545.0')
  return { serie, ordinal }
}

const getOtherSerieWorks = (worksUris, lastOrdinal) => async serie => {
  const partsData = await serie.fetchPartsData()
  const partsDataWithoutCurrentWorks = getReorderedParts(partsData, worksUris, lastOrdinal)
  return _.pluck(partsDataWithoutCurrentWorks, 'uri')
}

const getReorderedParts = function (partsData, worksUris, lastOrdinal) {
  if (lastOrdinal == null) {
    return partsData.filter(part => !worksUris.includes(part.uri))
  }

  const partsBefore = []
  const partsAfter = []
  const partsWithoutOrdinal = []

  for (const part of partsData) {
    if (!worksUris.includes(part.uri)) {
      const parsedOrdinal = parseOrdinal(part.ordinal)
      if (parsedOrdinal) {
        if (parsedOrdinal > lastOrdinal) partsAfter.push(part)
        else partsBefore.push(part)
      } else {
        partsWithoutOrdinal.push(part)
      }
    }
  }

  // Return the parts directly after the current one first
  return partsAfter.concat(partsBefore, partsWithoutOrdinal)
}
