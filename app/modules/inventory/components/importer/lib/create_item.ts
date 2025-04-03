import { API } from '#app/api/api'
import app from '#app/app'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import type { SerializedEntity } from '#entities/lib/entities'
import type { ItemTransactionMode } from '#server/types/item'
import type { ShelfId } from '#server/types/shelf'
import type { VisibilityKey } from '#server/types/visibility'

export async function createItemFromCandidate ({ candidate, transaction, visibility, shelvesIds }) {
  const { edition, details, notes } = candidate
  try {
    const item = await createItem({ edition, details, notes, transaction, visibility, shelves: shelvesIds })
    candidate.item = item
  } catch (err) {
    // Do not throw to not crash the whole chain
    const { responseJSON } = err
    candidate.error = responseJSON
  }
}

interface CreateItemParams {
  edition: SerializedEntity
  details: string
  notes?: string
  transaction: ItemTransactionMode
  visibility: VisibilityKey[]
  shelves?: ShelfId[]
}

export async function createItem ({ edition, details, notes, transaction, visibility, shelves }: CreateItemParams) {
  const { uri: editionUri } = edition
  app.request('last:transaction:set', transaction)
  app.execute('last:visibility:set', visibility)
  const itemData = {
    transaction,
    visibility,
    notes,
    details,
    shelves,
    entity: editionUri,
  }
  const item = await preq.post(API.items.base, itemData)
  log_.info('new item created', editionUri)
  return item
}
