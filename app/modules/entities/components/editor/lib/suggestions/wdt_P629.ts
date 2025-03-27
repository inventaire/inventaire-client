import { pluck, intersection, compact, uniq, without, difference } from 'underscore'
import { API } from '#app/api/api'
import { isPositiveIntegerString } from '#app/lib/boolean_tests'
import { treq } from '#app/lib/preq'
import { uniqSortedByCount } from '#app/lib/utils'
import { isNonEmptyClaimValue } from '#entities/components/editor/lib/editors_helpers'
import { getEntitiesList, getEntityByUri, getReverseClaims, type SerializedEntity } from '#entities/lib/entities'
import { getAuthorWorksUris } from '#entities/lib/types/author_alt'
import { getWorkAuthorsUris, getWorkSeriesUris } from '#inventory/components/lib/item_show_helpers'
import type { GetSeriePartsResponse } from '#server/controllers/entities/get_entity_relatives'
import type { SeriePart } from '#server/controllers/entities/lib/get_serie_parts'
import type { EntityUri } from '#server/types/entity'

export default async function ({ entity }: { entity: SerializedEntity }) {
  const { uri } = entity
  let editionWorksUris = entity.claims['wdt:P629']
  if (editionWorksUris == null) return
  editionWorksUris = editionWorksUris.filter(isNonEmptyClaimValue)
  const suggestionsUris = await Promise.all([
    getSuggestionsFromMultiWorksEditions(uri, editionWorksUris),
    getSuggestionsFromWorks(editionWorksUris),
  ])
  return uniq(suggestionsUris.flat())
}

async function getSuggestionsFromMultiWorksEditions (editionUri: EntityUri, editionWorksUris: EntityUri[]) {
  const worksEditionsUris = await Promise.all(editionWorksUris.map(workUri => getReverseClaims('wdt:P629', workUri)))
  const otherEditionsUris = without(uniq(worksEditionsUris.flat()), editionUri)
  const otherEditions = await getEntitiesList({ uris: otherEditionsUris, attributes: [ 'claims' ] })
  const otherEditionsWorksUris = otherEditions.flatMap(edition => edition.claims['wdt:P629'])
  const editionsOtherWorksUris = difference(otherEditionsWorksUris, editionWorksUris)
  return uniqSortedByCount(editionsOtherWorksUris)
}

async function getSuggestionsFromWorks (editionWorksUris: EntityUri[]) {
  const works = await getEntitiesList({ uris: editionWorksUris, attributes: [ 'claims' ] })
  const worksAuthors = works.map(getWorkAuthorsUris)
  const worksSeries = compact(works.map(getWorkSeriesUris))
  const commonAuthors = intersection(...worksAuthors)
  const commonSeries = intersection(...worksSeries)
  if (commonSeries.length === 1) {
    const otherSerieWorks = await getSuggestionsFromSerie(commonSeries[0], works, editionWorksUris)
    if (otherSerieWorks) return otherSerieWorks
  }
  if (commonAuthors.length === 1) {
    return getSuggestionsFromAuthor(commonAuthors[0], editionWorksUris)
  }
}

async function getSuggestionsFromSerie (serieUri: EntityUri, works: SerializedEntity[], editionWorksUris: EntityUri[]) {
  const worksSeriesData = getSeriesData(works)
  const lastOrdinal = getOrdinals(worksSeriesData, serieUri).slice(-1)[0]
  const serie = await getEntityByUri({ uri: serieUri })
  if (serie.type !== 'serie') return
  return getOtherSerieWorks(serie, editionWorksUris, lastOrdinal)
}

async function getSuggestionsFromAuthor (authorUri: EntityUri, editionWorksUris: EntityUri[]) {
  const author = await getEntityByUri({ uri: authorUri })
  if (author.type !== 'human') return
  const { seriesUris, worksUris } = await getAuthorWorksUris({ uri: author.uri })
  return difference(seriesUris.concat(worksUris), editionWorksUris)
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
