import { uniq, compact } from 'underscore'
import { getEntitiesList, getEntityByUri, type SerializedEntity } from '#entities/lib/entities'
import type { Label } from '#server/types/entity'

export async function getEditionSeriesLabels (edition: SerializedEntity) {
  const worksUris = edition.claims['wdt:P629']
  if (worksUris == null || worksUris.length === 0) return
  const works = await getEntitiesList({ uris: worksUris })
  const seriesUris = compact(uniq(works.map(work => work.claims['wdt:P179']).flat()))
  if (seriesUris.length !== 1) return
  const serie = await getEntityByUri({ uri: seriesUris[0] })
  return {
    uri: serie.uri,
    labels: uniq(Object.values(serie.labels)),
  }
}

export async function getWorkSeriesLabels (work: SerializedEntity) {
  const seriesUris = work.claims['wdt:P179']
  if (seriesUris?.length !== 1) return
  const serie = await getEntityByUri({ uri: seriesUris[0] })
  return {
    uri: serie.uri,
    labels: uniq(Object.values(serie.labels)),
  }
}

const volumePattern = /\s*(v|vol|volume|t|tome)?\.?\s*(\d+)?$/

// Display the tip if the serie label is used in addition to another title.
// If it's just the serie label, plus possibly a volume number, the tip isn't helpful
export function findMatchingSerieLabel (value: string, serieLabels: Label[]) {
  value = value
    .toLowerCase()
    // Ignore volume information to determine if there is a match with the serie label
    .replace(volumePattern, '')
    .trim()

  for (const label of serieLabels) {
    // Start with the serie label, followed by a separator
    // and some title of at least 5 characters
    const re = new RegExp(`^${label}\\s?(:|-|,).{3}`, 'i')
    if (re.test(value)) return label
  }
}
