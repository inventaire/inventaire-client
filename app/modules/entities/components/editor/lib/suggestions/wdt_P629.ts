import { pluck, intersection, compact, uniq, without, difference } from 'underscore'
import { API } from '#app/api/api'
import app from '#app/app'
import { isPositiveIntegerString } from '#app/lib/boolean_tests'
import { treq } from '#app/lib/preq'
import { uniqSortedByCount } from '#app/lib/utils'
import { getEntitiesList, getEntityByUri, getReverseClaims, getWorkAuthorsUris, type SerializedEntity } from '#app/modules/entities/lib/entities'
import { getWorkSeriesUris } from '#app/modules/inventory/components/lib/item_show_helpers'
import { isNonEmptyClaimValue } from '#entities/components/editor/lib/editors_helpers'
import type { GetSeriePartsResponse } from '#server/controllers/entities/get_entity_relatives'
import type { SeriePart } from '#server/controllers/entities/lib/get_serie_parts'
import type { EntityUri } from '#server/types/entity'

export default async function ({ entity }) {
  const { uri } = entity
  let worksUris = entity.claims['wdt:P629']
  if (worksUris == null) return
  worksUris = worksUris.filter(isNonEmptyClaimValue)
  const suggestionsUris = await Promise.all([
    getSuggestionsFromMultiWorksEditions(uri, worksUris),
    getSuggestionsFromWorks(worksUris),
  ])
  return uniq(suggestionsUris.flat())
}

async function getSuggestionsFromMultiWorksEditions (editionUri: EntityUri, worksUris: EntityUri[]) {
  const worksEditionsUris = await Promise.all(worksUris.map(workUri => getReverseClaims('wdt:P629', workUri)))
  const otherEditionsUris = without(uniq(worksEditionsUris.flat()), editionUri)
  const editions = await getEntitiesList({ uris: otherEditionsUris, attributes: [ 'claims' ] })
  const editionsWorksUris = editions.flatMap(edition => edition.claims['wdt:P629'])
  const editionsOtherWorksUris = difference(editionsWorksUris, worksUris)
  return uniqSortedByCount(editionsOtherWorksUris)
}

async function getSuggestionsFromWorks (worksUris: EntityUri[]) {
  const works = await getEntitiesList({ uris: worksUris, attributes: [ 'claims' ] })
  const worksAuthors = works.map(getWorkAuthorsUris)
  const worksSeries = compact(works.map(getWorkSeriesUris))
  const commonAuthors = intersection(...worksAuthors)
  const commonSeries = intersection(...worksSeries)
  if (commonSeries.length === 1) {
    const otherSerieWorks = await getSuggestionsFromSerie(commonSeries[0], works, worksUris)
    if (otherSerieWorks) return otherSerieWorks
  }
  if (commonAuthors.length === 1) {
    return getSuggestionsFromAuthor(commonAuthors[0], worksUris)
  }
}

async function getSuggestionsFromSerie (serieUri: EntityUri, works: SerializedEntity[], worksUris: EntityUri[]) {
  const worksSeriesData = getSeriesData(works)
  const lastOrdinal = getOrdinals(worksSeriesData, serieUri).slice(-1)[0]
  const serie = await getEntityByUri({ uri: serieUri })
  if (serie.type !== 'serie') return
  return getOtherSerieWorks(serie, worksUris, lastOrdinal)
}

async function getSuggestionsFromAuthor (authorUri: EntityUri, worksUris: EntityUri[]) {
  const author = await app.request('get:entity:model', authorUri)
  if (author.get('type') !== 'human') return
  const { works: authorWorksData } = await author.fetchWorksData()
  return pluck(authorWorksData, 'uri')
  .filter(uri => !worksUris.includes(uri))
}

function getSeriesData (works: SerializedEntity[]) {
  return works
  .map(getSerieData)
  // Filter-out empty results as it would make the intersection hereafter empty
  .filter(data => data.serie != null)
}

function getOrdinals (worksSeriesData: ReturnType<typeof getSeriesData>, serieUri: EntityUri) {
  return worksSeriesData
  .filter(data => (data.serie === serieUri) && isPositiveIntegerString(data.ordinal))
  .map(data => parseOrdinal(data.ordinal))
  .sort((a, b) => a - b)
}

function parseOrdinal (ordinal: string) {
  if (isPositiveIntegerString(ordinal)) return parseInt(ordinal)
}

function getSerieData (work: SerializedEntity) {
  const serie = work.claims['wdt:P179'][0]
  const ordinal = work.claims['wdt:P1545'][0]
  return { serie, ordinal }
}

async function getOtherSerieWorks (serie: SerializedEntity, worksUris: EntityUri[], lastOrdinal: number) {
  const { parts } = await treq.get<GetSeriePartsResponse>(API.entities.serieParts(serie.uri))
  const partsDataWithoutCurrentWorks = getReorderedParts(parts, worksUris, lastOrdinal)
  return pluck(partsDataWithoutCurrentWorks, 'uri')
}

function getReorderedParts (parts: SeriePart[], worksUris: EntityUri[], lastOrdinal: number) {
  if (lastOrdinal == null) {
    return parts.filter(part => !worksUris.includes(part.uri))
  }

  const partsBefore = []
  const partsAfter = []
  const partsWithoutOrdinal = []

  for (const part of parts) {
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
