leven = require 'leven'

module.exports = (serie)-> (work)->
  authorsScore = getAuthorsIntersectionLength(serie, work) * 10
  smallestLabelDistance = getSmallestLabelDistance serie, work
  pertinanceScore = authorsScore - smallestLabelDistance
  authorMatch = authorsScore > 0
  labelMatch = smallestLabelDistance < 5
  work.set { pertinanceScore, labelMatch, authorMatch }
  return work

getAuthorsIntersectionLength = (serie, work)->
  workAuthorsUris = work.getExtendedAuthorsUris()
  serieAuthorsUris = serie.getExtendedAuthorsUris()
  intersection = _.intersection workAuthorsUris, serieAuthorsUris
  return intersection.length

getSmallestLabelDistance = (serie, work)->
  serieLabels = _.values serie.get('labels')
  workLabels = _.values work.get('labels')
  labelsScores = serieLabels.map (serieLabel)-> workLabels.map distance(serieLabel)
  return _.min _.flatten(labelsScores)

distance = (serieLabel)-> (workLabel)->
  if workLabel.match new RegExp(serieLabel, 'i') then return 0
  rawDistance = leven serieLabel, workLabel
  truncatedDistance = leven serieLabel, workLabel.slice(0, serieLabel.length)
  return _.min [ rawDistance, truncatedDistance ]
