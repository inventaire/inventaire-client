leven = require 'leven'

module.exports = (invModels, wdModels)->
  candidates = {}

  invModels.forEach addLabelsParts
  wdModels.forEach addLabelsParts

  # Regroup candidates by invModel
  for invModel in invModels
    invUri = invModel.get 'uri'
    # invModel._alreadyPassed = true
    candidates[invUri] = { invModel, possibleDuplicateOf: [] }

    for wdModel in wdModels
      addCloseEntitiesToMergeCandidates invModel, candidates, wdModel

    for otherInvModel in invModels
      # Avoid adding duplicate candidates in both directions
      unless otherInvModel.get('uri') is invUri
        addCloseEntitiesToMergeCandidates invModel, candidates, otherInvModel

  return _.values candidates
  .filter hasPossibleDuplicates
  .map (candidate)->
    # Sorting so that the first model is the closest
    candidate.possibleDuplicateOf.sort byMatchLength(invUri)
    return candidate

addLabelsParts =  (model)-> model._labelsParts or= getLabelsParts getFormattedLabels(model)

getFormattedLabels = (model)->
  _.values model.get('labels')
  .map (label)->
    label.toLowerCase()
    # Remove anything after a '(' or a '['
    # as some titles might still have comments between parenthesis
    # ex: 'some book title (French edition)'
    .replace /(\(|\[).*$/, ''
    # Ignore leading articles as they are a big source of false negative match
    .replace /^(the|a|le|la|l'|der|die|das)\s/ig, ''
    .trim()

getLabelsParts = (labels)->
  parts = labels.map (label)->
    label
    .split titleSeparator
    # Filter-out parts that are just the serie name and the volume number
    .filter isntVolumeNumber
  return _.uniq _.flatten(parts)

titleSeparator = /\s*[-,:]\s+/
volumePattern = /(vol|volume|t|tome)\s\d+$/
isntVolumeNumber = (part)-> not volumePattern.test(part)

addCloseEntitiesToMergeCandidates = (invModel, candidates, otherModel)->
  invUri = invModel.get 'uri'
  otherModelUri = otherModel.get 'uri'
  partsA = invModel._labelsParts
  partsB = otherModel._labelsParts
  data = getBestMatchScore partsA, partsB
  if data.bestMatchScore > 0
    _.log data, "#{invUri} - #{otherModelUri}"
    otherModel.bestMatchScore or= {}
    otherModel.bestMatchScore[invUri] = data.bestMatchScore
    candidates[invUri].possibleDuplicateOf.push otherModel

  return

getBestMatchScore = (aLabelsParts, bLabelsParts)->
  data = { bestMatchScore: 0 }

  for aPart in aLabelsParts
    for bPart in bLabelsParts
      [ shortest, longest ] = getShortestAndLongest aPart.length, bPart.length
      # Do not compare parts that are very different in length
      if longest - shortest < 5
        distance = leven aPart, bPart
        matchScore = longest - distance
        matchRatio = matchScore / longest
        matchRatio = Math.round(matchRatio * 100) / 100
        if distance < 5 and matchRatio > 0.6 and matchScore > data.bestMatchScore
          data = { aPart, bPart, bestMatchScore: matchScore, matchRatio, distance }

  return data

getShortestAndLongest = (a, b)-> if a > b then [ b, a ] else [ a, b ]

hasPossibleDuplicates = (candidate)->
  possibleCandidatesCount = candidate.possibleDuplicateOf.length
  # Also ignore when there are too many candidates
  return possibleCandidatesCount > 0 and possibleCandidatesCount < 10

byMatchLength = (invUri)->(a, b)-> b.bestMatchScore[invUri] - a.bestMatchScore[invUri]
