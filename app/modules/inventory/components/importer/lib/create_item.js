import log_ from '#lib/loggers'
import preq from '#lib/preq'

export const createItem = async (edition, details, notes, transaction, listing, shelves) => {
  if (!edition?.uri) return
  const { uri: editionUri } = edition
  const itemData = {
    transaction,
    listing,
    notes,
    details,
    shelves,
    entity: editionUri
  }
  const item = await preq.post(app.API.items.base, itemData)
  log_.info('new item created', editionUri)
  return item
}
