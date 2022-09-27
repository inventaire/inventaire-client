import assert_ from '#lib/assert_types'
import log_ from '#lib/loggers'
import { i18n } from '#user/lib/i18n'
import preq from '#lib/preq'
import Item from '#inventory/models/item'
import { isModel } from '#lib/boolean_tests'
import { hasSubscribers, refreshDocStore, updateDocStore } from '#lib/svelte/mono_document_stores'
import { addItemsUsers } from '#inventory/lib/queries'

export default {
  create (itemData) {
    log_.info(itemData, 'item data before creation')

    return preq.post(app.API.items.base, itemData)
    .then(log_.Info('item data after creation'))
    .then(data => {
      const model = new Item(data)
      app.user.trigger('items:change', null, model.get('listing'))
      return model
    })
  },

  async update (options) {
    // expects: items (models or ids), attribute, value
    // optional: selector
    let { item, items, attribute, value, selector } = options
    if ((items == null) && (item != null)) items = [ item ]
    assert_.array(items)
    assert_.string(attribute)
    if (selector != null) assert_.string(selector)

    items.forEach(item => {
      if (_.isString(item)) return
      if (isModel(item)) {
        item._backup = item.toJSON()
        item.set(attribute, value)
      }
    })

    const ids = items.map(getItemId)

    try {
      // Optimistic UI
      propagateItemsChanges({ ids, attribute, value })
      await preq.put(app.API.items.update, { ids, attribute, value })
    } catch (err) {
      // Revert optimistic changes
      await reconcileWithServerState(ids)
      throw err
    }
  },

  delete (options) {
    let confirmationText
    const { items, next, back } = options
    assert_.types([ items, next ], [ 'array', 'function' ])

    const ids = items.map(getItemId)

    const action = async () => {
      const res = await preq.post(app.API.items.deleteByIds, { ids })
      items.forEach(item => {
        if (_.isString(item)) return
        // app.user.trigger('items:change', item.get('listing'), null)
        item.hasBeenDeleted = true
      })
      return next(res)
    }

    if ((items.length === 1)) {
      let title
      if (isModel(items[0])) {
        title = items[0].get('snapshot.entity:title')
      } else {
        title = items[0].snapshot?.['entity:title']
      }
      confirmationText = i18n('delete_item_confirmation', { title })
    } else {
      confirmationText = i18n('delete_items_confirmation', { amount: ids.length })
    }

    const warningText = i18n('cant_undo_warning')

    app.execute('ask:confirmation', { confirmationText, warningText, action, back })
  }
}

const getItemId = item => {
  if (_.isString(item)) return item
  // Support both models and item docs
  else return item.id || item._id
}

const propagateItemsChanges = async ({ ids, attribute, value }) => {
  const updateFn = doc => {
    doc[attribute] = value
    return doc
  }
  ids.forEach(id => updateDocStore({ category: 'items', id, updateFn }))
}

const reconcileWithServerState = async ids => {
  ids = ids.filter(id => hasSubscribers('items', id))
  if (ids.length === 0) return
  const { items, users } = await preq.get(app.API.items.byIds({ ids, includeUsers: true }))
  addItemsUsers({ items, users })
  items.forEach(doc => refreshDocStore({ category: 'items', doc }))
}
