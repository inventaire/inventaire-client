import log_ from '#lib/loggers'
import preq from '#lib/preq'

export const createItemFromCandidate = async ({ candidate, transaction, visibility, shelvesIds }) => {
  const { edition, details, notes } = candidate
  try {
    const item = await createItem(edition, details, notes, transaction, visibility, shelvesIds)
    candidate.item = item
  } catch (err) {
    // Do not throw to not crash the whole chain
    const { responseJSON } = err
    candidate.error = responseJSON
  }
}

export const createItem = async (edition, details, notes, transaction, visibility, shelves) => {
  if (!edition?.uri) return
  const { uri: editionUri } = edition
  const itemData = {
    transaction,
    visibility,
    notes,
    details,
    shelves,
    entity: editionUri
  }
  const item = await preq.post(app.API.items.base, itemData)
  log_.info('new item created', editionUri)
  return item
}
