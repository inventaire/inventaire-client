import { pluck, range } from 'underscore'
import type { SeriePartPlaceholder } from '#entities/components/cleanup/lib/add_placeholders_for_missing_parts'
import { getEntitiesList, getReverseClaims, type SerializedEntity } from '#entities/lib/entities'
import type { EntityUri } from '#server/types/entity'

export type WorkWithEditions = SerializedEntity & { editions?: SerializedEntity[] }

export function getAvailableOrdinals (worksWithOrdinal: (SerializedEntity | SeriePartPlaceholder)[]) {
  const nonPlaceholdersWorksWithOrdinals = worksWithOrdinal.filter(workIsNotPlaceholder)
  const usedOrdinals = pluck(nonPlaceholdersWorksWithOrdinals, 'serieOrdinalNum')
  const maxOrdinal = Math.max(...usedOrdinals, -1)
  return range(0, (maxOrdinal + 10))
    .filter(num => !usedOrdinals.includes(num))
}

export function workIsPlaceholder (work: SerializedEntity | SeriePartPlaceholder): work is SeriePartPlaceholder {
  return ('isPlaceholder' in work && work.isPlaceholder)
}

export function workIsNotPlaceholder (work: SerializedEntity | SeriePartPlaceholder): work is SerializedEntity {
  return !workIsPlaceholder(work)
}

export function sortByLabel (a: SerializedEntity, b: SerializedEntity) {
  return a.label > b.label ? 1 : -1
}

export function sortByOrdinal (a: SerializedEntity, b: SerializedEntity) {
  if (a.serieOrdinalNum != null && b.serieOrdinalNum != null) {
    return a.serieOrdinalNum - b.serieOrdinalNum
  } else if (a.serieOrdinalNum != null) {
    return -1
  } else {
    return 1
  }
}

export async function getIsolatedEditions (serieUri: EntityUri) {
  const directSerieEditionsUris = await getReverseClaims('wdt:P629', serieUri, true)
  const editions = await getEntitiesList({ uris: directSerieEditionsUris, refresh: true })
  return editions
}
