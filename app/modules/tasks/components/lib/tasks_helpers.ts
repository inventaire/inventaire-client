import { intersection } from 'underscore'

export const calculateGlobalScore = task => {
  const { externalSourcesOccurrences, lexicalScore, relationScore } = task
  let score = 0
  const externalSourcesOccurrencesCount = externalSourcesOccurrences.length
  if (externalSourcesOccurrencesCount) score += 80 * externalSourcesOccurrencesCount
  if (lexicalScore) score += lexicalScore
  if (relationScore) score += relationScore * 10
  return Math.trunc(score * 100) / 100
}

export function sortMatchedLabelsEntities (entities, matchedTitles) {
  return entities.sort((a, b) => hasMatchedLabel(a, matchedTitles) < hasMatchedLabel(b, matchedTitles) ? 1 : -1)
}

export function hasMatchedLabel (entity, matchedTitles) {
  const entityLabels = Object.values(entity.labels)
  const matchedLabels = intersection(matchedTitles, entityLabels)
  return matchedLabels.length > 0
}
