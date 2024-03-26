import leven from 'leven'
import { min, flatten, intersection } from 'underscore'

export default serie => function (work) {
  const authorsScore = getAuthorsIntersectionLength(serie, work) * 10
  const smallestLabelDistance = getSmallestLabelDistance(serie, work)
  const pertinanceScore = authorsScore - smallestLabelDistance
  const authorMatch = authorsScore > 0
  const labelMatch = smallestLabelDistance < 5
  work.set({ pertinanceScore, labelMatch, authorMatch })
  return work
}

const getAuthorsIntersectionLength = function (serie, work) {
  const workAuthorsUris = work.getExtendedAuthorsUris()
  const serieAuthorsUris = serie.getExtendedAuthorsUris()
  return intersection(workAuthorsUris, serieAuthorsUris).length
}

const getSmallestLabelDistance = function (serie, work) {
  const serieLabels = Object.values(serie.get('labels'))
  const workLabels = Object.values(work.get('labels'))
  const labelsScores = serieLabels.map(serieLabel => workLabels.map(distance(serieLabel)))
  return min(flatten(labelsScores))
}

const distance = serieLabel => function (workLabel) {
  if (workLabel.match(new RegExp(serieLabel, 'i'))) return 0
  const rawDistance = leven(serieLabel, workLabel)
  const truncatedDistance = leven(serieLabel, workLabel.slice(0, serieLabel.length))
  return min([ rawDistance, truncatedDistance ])
}
