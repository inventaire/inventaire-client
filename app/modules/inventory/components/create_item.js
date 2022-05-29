import log_ from '#lib/loggers'
import preq from '#lib/preq'
import { tap } from '#lib/promises'

export const createItem = async (edition, details, notes, transaction, listing, shelves) => {
  if (!edition) return
  const { uri: editionUri } = edition
  if (!editionUri) return
  const itemData = {
    transaction,
    listing,
    notes,
    details,
    shelves,
    entity: editionUri
  }
  return preq.post(app.API.items.base, itemData)
  .then(tap(item => log_.info('new item created', editionUri)))
}
