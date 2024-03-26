import { uniq, compact } from 'underscore'
import app from '#app/app'

export async function getEditionSeriesLabels (edition) {
  const worksUris = edition.claims['wdt:P629']
  if (worksUris == null || worksUris.length === 0) return
  const works = await app.request('get:entities:models', { uris: worksUris })
  const seriesUris = compact(uniq(works.map(work => work.get('claims.wdt:P179')).flat()))
  if (seriesUris.length !== 1) return
  const serie = await app.request('get:entity:model', seriesUris[0])
  return {
    uri: serie.get('uri'),
    labels: uniq(Object.values(serie.get('labels'))),
  }
}

export async function getWorkSeriesLabels (work) {
  const seriesUris = work.claims['wdt:P179']
  if (seriesUris?.length !== 1) return
  const serie = await app.request('get:entity:model', seriesUris[0])
  return {
    uri: serie.get('uri'),
    labels: uniq(Object.values(serie.get('labels'))),
  }
}

const volumePattern = /\s*(v|vol|volume|t|tome)?\.?\s*(\d+)?$/

// Display the tip if the serie label is used in addition to another title.
// If it's just the serie label, plus possibly a volume number, the tip isn't helpful
export function findMatchingSerieLabel (value, serieLabels) {
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
