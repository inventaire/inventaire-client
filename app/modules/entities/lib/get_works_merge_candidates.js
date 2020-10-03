import log_ from 'lib/loggers'
import leven from 'leven'

export default function (invModels, wdModels) {
  let invUri
  const candidates = {}

  invModels.forEach(addLabelsParts)
  wdModels.forEach(addLabelsParts)

  // Regroup candidates by invModel
  for (const invModel of invModels) {
    invUri = invModel.get('uri')
    // invModel._alreadyPassed = true
    candidates[invUri] = { invModel, possibleDuplicateOf: [] }

    for (const wdModel of wdModels) {
      addCloseEntitiesToMergeCandidates(invModel, candidates, wdModel)
    }

    for (const otherInvModel of invModels) {
      // Avoid adding duplicate candidates in both directions
      if (otherInvModel.get('uri') !== invUri) {
        addCloseEntitiesToMergeCandidates(invModel, candidates, otherInvModel)
      }
    }
  }

  return _.values(candidates)
  .filter(hasPossibleDuplicates)
  .map(candidate => {
    // Sorting so that the first model is the closest
    candidate.possibleDuplicateOf.sort(byMatchLength(invUri))
    return candidate
  })
};

const addLabelsParts = model => model._labelsParts || (model._labelsParts = getLabelsParts(getFormattedLabels(model)))

const getFormattedLabels = model => _.values(model.get('labels'))
.map(label => label.toLowerCase()
// Remove anything after a '(' or a '['
// as some titles might still have comments between parenthesis
// ex: 'some book title (French edition)'
.replace(/(\(|\[).*$/, '')
// Ignore leading articles as they are a big source of false negative match
.replace(/^(the|a|le|la|l'|der|die|das)\s/ig, '')
.trim())

const getLabelsParts = function (labels) {
  const parts = labels.map(label => label
  .split(titleSeparator)
  // Filter-out parts that are just the serie name and the volume number
  .filter(isntVolumeNumber))
  return _.uniq(_.flatten(parts))
}

const titleSeparator = /\s*[-,:]\s+/
const volumePattern = /(vol|volume|t|tome)\s\d+$/
const isntVolumeNumber = part => !volumePattern.test(part)

const addCloseEntitiesToMergeCandidates = function (invModel, candidates, otherModel) {
  const invUri = invModel.get('uri')
  const otherModelUri = otherModel.get('uri')
  const partsA = invModel._labelsParts
  const partsB = otherModel._labelsParts
  const data = getBestMatchScore(partsA, partsB)
  if (data.bestMatchScore > 0) {
    log_.info(data, `${invUri} - ${otherModelUri}`)
    if (!otherModel.bestMatchScore) { otherModel.bestMatchScore = {} }
    otherModel.bestMatchScore[invUri] = data.bestMatchScore
    candidates[invUri].possibleDuplicateOf.push(otherModel)
  }
}

const getBestMatchScore = function (aLabelsParts, bLabelsParts) {
  let data = { bestMatchScore: 0 }

  for (const aPart of aLabelsParts) {
    for (const bPart of bLabelsParts) {
      const [ shortest, longest ] = Array.from(getShortestAndLongest(aPart.length, bPart.length))
      // Do not compare parts that are very different in length
      if ((longest - shortest) < 5) {
        const distance = leven(aPart, bPart)
        const matchScore = longest - distance
        let matchRatio = matchScore / longest
        matchRatio = Math.round(matchRatio * 100) / 100
        if ((distance < 5) && (matchRatio > 0.6) && (matchScore > data.bestMatchScore)) {
          data = { aPart, bPart, bestMatchScore: matchScore, matchRatio, distance }
        }
      }
    }
  }

  return data
}

const getShortestAndLongest = function (a, b) { if (a > b) { return [ b, a ] } else { return [ a, b ] } }

const hasPossibleDuplicates = function (candidate) {
  const possibleCandidatesCount = candidate.possibleDuplicateOf.length
  // Also ignore when there are too many candidates
  return (possibleCandidatesCount > 0) && (possibleCandidatesCount < 10)
}

const byMatchLength = invUri => (a, b) => b.bestMatchScore[invUri] - a.bestMatchScore[invUri]
