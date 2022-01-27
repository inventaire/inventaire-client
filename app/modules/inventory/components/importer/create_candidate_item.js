import preq from '#lib/preq'

export const createCandidateItem = async (candidate, importErr, transaction, listing) => {
  const { edition, isbn, checked } = candidate
  if (!checked || !edition || importErr.includes(isbn)) return
  const { uri: editionUri } = edition
  if (!editionUri) return
  const itemData = {
    transaction,
    listing,
    details: candidate.details,
    entity: editionUri
  }
  return preq.post(app.API.items.base, itemData)
}
