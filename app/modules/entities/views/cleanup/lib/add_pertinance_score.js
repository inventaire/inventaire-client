import leven from 'leven'

export default serie => function (work) {
  const authorsScore = getAuthorsIntersectionLength(serie, work) * 10
  const smallestLabelDistance = getSmallestLabelDistance(serie, work)
  const pertinanceScore = authorsScore - smallestLabelDistance
  const authorMatch = authorsScore > 0
  const labelMatch = smallestLabelDistance < 5
  work.set({ pertinanceScore, labelMatch, authorMatch })
  return work
}

var getAuthorsIntersectionLength = function (serie, work) {
  const workAuthorsUris = work.getExtendedAuthorsUris()
  const serieAuthorsUris = serie.getExtendedAuthorsUris()
  const intersection = _.intersection(workAuthorsUris, serieAuthorsUris)
  return intersection.length
}

var getSmallestLabelDistance = function (serie, work) {
  const serieLabels = _.values(serie.get('labels'))
  const workLabels = _.values(work.get('labels'))
  const labelsScores = serieLabels.map(serieLabel => workLabels.map(distance(serieLabel)))
  return _.min(_.flatten(labelsScores))
}

var distance = serieLabel => function (workLabel) {
  if (workLabel.match(new RegExp(serieLabel, 'i'))) { return 0 }
  const rawDistance = leven(serieLabel, workLabel)
  const truncatedDistance = leven(serieLabel, workLabel.slice(0, serieLabel.length))
  return _.min([ rawDistance, truncatedDistance ])
}
