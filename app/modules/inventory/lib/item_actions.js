import assert_ from 'lib/assert_types'
import log_ from 'lib/loggers'
import { i18n } from 'modules/user/lib/i18n'
import preq from 'lib/preq'
import Item from 'modules/inventory/models/item'

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
      item._backup = item.toJSON()
      return item.set(attribute, value)
    })

    const ids = items.map(getIdFromModelOrId)

    try {
      await preq.put(app.API.items.update, { ids, attribute, value })
      propagateItemsChanges(items, attribute)
    } catch (err) {
      rollbackUpdate(items)
      throw err
    }
  },

  delete (options) {
    let confirmationText
    const { items, next, back } = options
    assert_.types([ items, next ], [ 'array', 'function' ])

    const ids = items.map(getIdFromModelOrId)

    const action = async () => {
      const res = await preq.post(app.API.items.deleteByIds, { ids })
      items.forEach(item => {
        if (_.isString(item)) return
        app.user.trigger('items:change', item.get('listing'), null)
        item.isDestroyed = true
      })
      return next(res)
    }

    if ((items.length === 1) && items[0] instanceof Backbone.Model) {
      const title = items[0].get('snapshot.entity:title')
      confirmationText = i18n('delete_item_confirmation', { title })
    } else {
      confirmationText = i18n('delete_items_confirmation', { amount: ids.length })
    }

    const warningText = i18n('cant_undo_warning')

    app.execute('ask:confirmation', { confirmationText, warningText, action, back })
  }
}

const getIdFromModelOrId = item => {
  if (_.isString(item)) return item
  else return item.id
}

const propagateItemsChanges = (items, attribute) => {
  items.forEach(item => {
    // TODO: update counters for non-model items too
    if (_.isString(item)) return
    if (attribute === 'listing') {
      const { listing: previousListing } = item._backup
      const newListing = item.get('listing')
      if (newListing === previousListing) return
      app.user.trigger('items:change', previousListing, newListing)
    }
    delete item._backup
  })
}

const rollbackUpdate = items => {
  items.forEach(item => {
    if (_.isString(item)) return
    item.set(item._backup)
    delete item._backup
  })
}
