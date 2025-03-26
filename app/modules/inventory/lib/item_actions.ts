import { API } from '#app/api/api'
import { isCouchUuid } from '#app/lib/boolean_tests'
import preq from '#app/lib/preq'
import { askConfirmation } from '#general/lib/confirmation_modal'
import type { ItemId, Item } from '#server/types/item'
import { I18n } from '#user/lib/i18n'
import { getItemById, serializeItem, type SerializedItem } from './items'

export async function createItem (itemData: Partial<Item>) {
  const item = await preq.post(API.items.base, itemData)
  return serializeItem(item)
}

interface UpdateItemsParams <T extends keyof Item> {
  items: SerializedItem[] | ItemId[]
  attribute: T
  value: Item[T]
}

export async function updateItems <T extends keyof Item> (params: UpdateItemsParams<T>) {
  const { items, attribute, value } = params
  const ids = items.map(getItemId)
  return preq.put(API.items.update, { ids, attribute, value })
}

interface DeleteItemsParams {
  items: SerializedItem[] | ItemId[]
  next: (res: unknown) => void
  back?: () => void
}

export async function deleteItems (params: DeleteItemsParams) {
  const { items, next, back } = params

  const ids = items.map(getItemId)

  const action = async () => {
    const res = await preq.post(API.items.deleteByIds, { ids })
    for (const item of items) {
      if (typeof item === 'object') item.hasBeenDeleted = true
    }
    return next(res)
  }

  let confirmationText
  if ((items.length === 1)) {
    let title
    const item = items[0]
    if (isCouchUuid(item)) {
      const serializedItem = await getItemById(item as ItemId)
      title = serializedItem.title
    } else {
      title = item.snapshot?.['entity:title']
    }
    confirmationText = I18n('delete_item_confirmation', { title })
  } else {
    confirmationText = I18n('delete_items_confirmation', { amount: ids.length })
  }

  const warningText = I18n('cant_undo_warning')

  askConfirmation({ confirmationText, warningText, action, back })
}

function getItemId (item: SerializedItem | ItemId) {
  if (typeof item === 'string') return item
  else return item._id
}
