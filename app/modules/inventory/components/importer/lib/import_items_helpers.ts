import { isResolved } from '#inventory/lib/importer/import_helpers'
import type { ItemTransactionMode } from '#serverTypes/item'

const transac: ItemTransactionMode = 'giving'
console.log('🚀 ~ file: import_items_helpers.ts ~ line', 5, { transac })

export const removeCreatedCandidates = ({ candidates, processedCandidates }) => {
  const createdIndices = processedCandidates.map(createdCandidate => {
    if (createdCandidate.item) return createdCandidate.index
  })
  return candidates.filter(candidate => !createdIndices.includes(candidate.index))
}

export const isAlreadyResolved = candidate => {
  const authorsResolved = candidate.authors?.every(isResolved)
  const worksResolved = candidate.works?.every(isResolved)
  return authorsResolved && worksResolved && candidate.edition
}
