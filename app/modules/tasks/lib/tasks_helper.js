export const calculateGlobalScore = task => {
  const { externalSourcesOccurrences, lexicalScore, relationScore } = task
  let score = 0
  const externalSourcesOccurrencesCount = externalSourcesOccurrences.length
  if (externalSourcesOccurrencesCount) score += 80 * externalSourcesOccurrencesCount
  if (lexicalScore) score += lexicalScore
  if (relationScore) score += relationScore * 10
  return Math.trunc(score * 100) / 100
}
