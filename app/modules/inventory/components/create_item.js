import log_ from '#lib/loggers'
import preq from '#lib/preq'
import { tap } from '#lib/promises'

export const createItem = async (edition, details, transaction, listing) => {
  if (!edition) return
  const { uri: editionUri } = edition
  if (!editionUri) return
  const itemData = {
    transaction,
    listing,
    details,
    entity: editionUri
  }
  return preq.post(app.API.items.base, itemData)
  .then(tap(item => log_.info('new item created', editionUri)))
}
