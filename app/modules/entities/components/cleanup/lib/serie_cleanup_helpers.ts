import { pluck, range } from 'underscore'
import type { SeriePartPlaceholder } from '#app/modules/entities/views/cleanup/lib/fill_gaps'
import { type SerializedEntity } from '#entities/lib/entities'

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
