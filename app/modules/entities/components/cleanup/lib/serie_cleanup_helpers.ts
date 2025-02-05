import { pluck, range } from 'underscore'
import { newError } from '#app/lib/error'
import type { SeriePartPlaceholder } from '#app/modules/entities/views/cleanup/lib/fill_gaps'
import { getEntitiesList, getReverseClaims, type SerializedEntity } from '#entities/lib/entities'
import type { EntityUri } from '#server/types/entity'

export type WorkWithEditions = SerializedEntity & { editions?: SerializedEntity[] }

export function getPossibleOrdinals (worksWithOrdinal: (SerializedEntity | SeriePartPlaceholder)[]) {
  const nonPlaceholdersWorksWithOrdinals = worksWithOrdinal.filter(workIsNotPlaceholder)
  const nonPlaceholdersOrdinals = pluck(nonPlaceholdersWorksWithOrdinals, 'serieOrdinalNum')
  const maxOrdinal = Math.max(...nonPlaceholdersOrdinals, -1)
  return range(0, (maxOrdinal + 10))
    .filter(num => !nonPlaceholdersOrdinals.includes(num))
}

export function workIsPlaceholder (work: SerializedEntity | SeriePartPlaceholder): work is SeriePartPlaceholder {
  return ('isPlaceholder' in work && work.isPlaceholder)
}

export function workIsNotPlaceholder (work: SerializedEntity | SeriePartPlaceholder): work is SerializedEntity {
  return !workIsPlaceholder(work)
}

export function assertWorkIsNotPlaceholder (work: SerializedEntity | SeriePartPlaceholder): asserts work is SerializedEntity {
  if (workIsNotPlaceholder(work)) throw newError('expected an existing work')
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
