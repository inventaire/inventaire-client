import leven from 'leven'
import { min, flatten, intersection, values } from 'underscore'
import type { SerializedEntity } from '#app/modules/entities/lib/entities'
import { getSerieOrWorkExtendedAuthorsUris } from '#app/modules/entities/lib/types/serie_alt'

interface WorkSuggestionExtras {
  pertinanceScore: number
  authorMatch: boolean
  labelMatch: boolean
}

export type WorkSuggestion = SerializedEntity & WorkSuggestionExtras

export function addPertinanceScore (serie: SerializedEntity) {
  return function (work: SerializedEntity & Partial<WorkSuggestionExtras>) {
    const authorsScore = getAuthorsIntersectionLength(serie, work) * 10
    const smallestLabelDistance = getSmallestLabelDistance(serie, work)
    work.pertinanceScore = authorsScore - smallestLabelDistance
    work.authorMatch = authorsScore > 0
    work.labelMatch = smallestLabelDistance < 5
    return work
  }
}

function getAuthorsIntersectionLength (serie: SerializedEntity, work: SerializedEntity) {
  const workAuthorsUris = getSerieOrWorkExtendedAuthorsUris(work)
  const serieAuthorsUris = getSerieOrWorkExtendedAuthorsUris(serie)
  return intersection(workAuthorsUris, serieAuthorsUris).length
}

function getSmallestLabelDistance (serie: SerializedEntity, work: SerializedEntity) {
  const serieLabels = values(serie.labels)
  const workLabels = values(work.labels)
  const labelsScores = serieLabels.map(serieLabel => workLabels.map(distance(serieLabel)))
  return min(flatten(labelsScores))
}

function distance (serieLabel: string) {
  return function (workLabel: string) {
    if (workLabel.match(new RegExp(serieLabel, 'i'))) return 0
    const rawDistance = leven(serieLabel, workLabel)
    const truncatedDistance = leven(serieLabel, workLabel.slice(0, serieLabel.length))
    return min([ rawDistance, truncatedDistance ])
  }
}
