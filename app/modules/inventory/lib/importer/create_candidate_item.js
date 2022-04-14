import preq from '#lib/preq'

export const createCandidateItem = async (candidate, importErr, transaction, listing) => {
  const { edition, isbn, checked, details, notes } = candidate
  if (!checked || !edition || importErr.includes(isbn)) return
  const { uri: editionUri } = edition
  if (!editionUri) return
  const itemData = {
    transaction,
    listing,
    details,
    notes,
    entity: editionUri
  }
  return preq.post(app.API.items.base, itemData)
}
