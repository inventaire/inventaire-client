import leven from 'leven'
import { uniq, flatten } from 'underscore'
import type { InvEntity } from '#server/types/entity'

type MatchData = {
  bestMatchScore: number
  aPart?: unknown
  bPart?: unknown
  matchRatio?: number
  distance?: number
}

interface MergeCandidate {
  invWork: InvEntity
  possibleDuplicateOf: MatchData[]
}

export default function (invWorks, wdWorks) {
  let invUri
  const candidates = {}

  invWorks.forEach(addLabelsParts)
  wdWorks.forEach(addLabelsParts)

  // Regroup candidates by invWork
  for (const invWork of invWorks) {
    invUri = invWork.uri
    // invWork._alreadyPassed = true
    const candidate: MergeCandidate = { invWork, possibleDuplicateOf: [] }
    candidates[invUri] = candidate

    for (const wdWork of wdWorks) {
      addCloseEntitiesToMergeCandidates(invWork, candidates, wdWork)
    }

    for (const otherInvWork of invWorks) {
      // Avoid adding duplicate candidates in both directions
      if (otherInvWork.uri !== invUri) {
        addCloseEntitiesToMergeCandidates(invWork, candidates, otherInvWork)
      }
    }
  }

  return Object.values(candidates)
  .filter(hasPossibleDuplicates)
  .map((candidate: MergeCandidate) => {
    // Sorting so that the first work is the closest
    candidate.possibleDuplicateOf.sort(byMatchLength(invUri))
    return candidate
  })
}

const addLabelsParts = work => work._labelsParts || (work._labelsParts = getLabelsParts(getFormattedLabels(work)))

function getFormattedLabels (work) {
  return Object.values(work.labels)
  .map((label: string) => {
    return label.toLowerCase()
    // Remove anything after a '(' or a '['
    // as some titles might still have comments between parenthesis
    // ex: 'some book title (French edition)'
    .replace(/(\(|\[).*$/, '')
    // Ignore leading articles as they are a big source of false negative match
    .replace(/^(the|a|le|la|l'|der|die|das)\s/ig, '')
    .trim()
  })
}

const getLabelsParts = function (labels) {
  const parts = labels.map(label => {
    return label
    .split(titleSeparator)
    // Filter-out parts that are just the serie name and the volume number
    .filter(isntVolumeNumber)
  })

  return uniq(flatten(parts))
}

const titleSeparator = /\s*[-,:]\s+/
const volumePattern = /(vol|volume|t|tome)\s\d+$/
const isntVolumeNumber = part => !volumePattern.test(part)

const addCloseEntitiesToMergeCandidates = function (invWork, candidates, otherWork) {
  const invUri = invWork.uri
  const partsA = invWork._labelsParts
  const partsB = otherWork._labelsParts
  const data = getBestMatchScore(partsA, partsB)
  if (data.bestMatchScore > 0) {
    if (!otherWork.bestMatchScore) otherWork.bestMatchScore = {}
    otherWork.bestMatchScore[invUri] = data.bestMatchScore
    candidates[invUri].possibleDuplicateOf.push(otherWork)
  }
}

const getBestMatchScore = function (aLabelsParts, bLabelsParts) {
  let data: MatchData = { bestMatchScore: 0 }

  for (const aPart of aLabelsParts) {
    for (const bPart of bLabelsParts) {
      const [ shortest, longest ] = getShortestAndLongest(aPart.length, bPart.length)
      // Do not compare parts that are very different in length
      if (longest - shortest < 5) {
        const distance = leven(aPart, bPart)
        const matchScore = longest - distance
        let matchRatio = matchScore / longest
        matchRatio = Math.round(matchRatio * 100) / 100
        if (distance < 5 && matchRatio > 0.6 && matchScore > data.bestMatchScore) {
          data = { aPart, bPart, bestMatchScore: matchScore, matchRatio, distance }
        }
      }
    }
  }

  return data
}

const getShortestAndLongest = (a, b) => a > b ? [ b, a ] : [ a, b ]

const hasPossibleDuplicates = function (candidate) {
  const possibleCandidatesCount = candidate.possibleDuplicateOf.length
  // Also ignore when there are too many candidates
  return possibleCandidatesCount > 0 && possibleCandidatesCount < 10
}

const byMatchLength = invUri => (a, b) => b.bestMatchScore[invUri] - a.bestMatchScore[invUri]
