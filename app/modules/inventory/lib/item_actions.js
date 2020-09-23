import Item from 'modules/inventory/models/item'

export default {
  create (itemData) {
    _.log(itemData, 'item data before creation')

    return _.preq.post(app.API.items.base, itemData)
    .then(_.Log('item data after creation'))
    .then(data => {
      const model = new Item(data)
      app.user.trigger('items:change', null, model.get('listing'))
      return model
    })
  },

  update (options) {
    // expects: items (models or ids), attribute, value
    // optional: selector
    let { item, items, attribute, value, selector } = options
    if ((items == null) && (item != null)) { items = [ item ] }
    _.type(items, 'array')
    _.type(attribute, 'string')
    if (selector != null) { _.type(selector, 'string') }

    items.forEach(item => {
      if (_.isString(item)) { return }
      item._backup = item.toJSON()
      return item.set(attribute, value)
    })

    const ids = items.map(getIdFromModelOrId)

    return _.preq.put(app.API.items.update, { ids, attribute, value })
    .tap(propagateItemsChanges(items, attribute))
    .catch(rollbackUpdate(items))
  },

  delete (options) {
    let confirmationText
    const { items, next, back } = options
    _.types([ items, next ], [ 'array', 'function' ])

    const ids = items.map(getIdFromModelOrId)

    const action = () => _.preq.post(app.API.items.deleteByIds, { ids })
    .tap(() => items.forEach(item => {
      if (_.isString(item)) { return }
      app.user.trigger('items:change', item.get('listing'), null)
      return item.isDestroyed = true
    })).then(next)

    if ((items.length === 1) && items[0] instanceof Backbone.Model) {
      const title = items[0].get('snapshot.entity:title')
      confirmationText = _.i18n('delete_item_confirmation', { title })
    } else {
      confirmationText = _.i18n('delete_items_confirmation', { amount: ids.length })
    }

    const warningText = _.i18n('cant_undo_warning')

    return app.execute('ask:confirmation', { confirmationText, warningText, action, back })
  }
}

var getIdFromModelOrId = function (item) { if (_.isString(item)) { return item } else { return item.id } }

var propagateItemsChanges = (items, attribute) => () => items.forEach(item => {
  // TODO: update counters for non-model items too
  if (_.isString(item)) { return }
  if (attribute === 'listing') {
    const { listing: previousListing } = item._backup
    const newListing = item.get('listing')
    if (newListing === previousListing) { return }
    app.user.trigger('items:change', previousListing, newListing)
  }
  return delete item._backup
})

var rollbackUpdate = items => function (err) {
  items.forEach(item => {
    if (_.isString(item)) { return }
    item.set(item._backup)
    return delete item._backup
  })
  throw err
}
