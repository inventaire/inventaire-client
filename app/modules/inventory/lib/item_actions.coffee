Item = require 'modules/inventory/models/item'

module.exports =
  create: (itemData)->
    _.log itemData, 'item data before creation'

    _.preq.post app.API.items.base, itemData
    .then _.Log('item data after creation')
    .then (data)-> new Item data

  update: (options)->
    # expects: items (models or ids), attribute, value
    # optional: selector
    { items, attribute, value, selector } = options
    _.type items, 'array'
    _.type attribute, 'string'
    if selector? then _.type selector, 'string'

    items.forEach (item)->
      if _.isString item then return
      item._backup = item.toJSON()
      item.set attribute, value

    ids = items.map (item)-> if _.isString item then item else item.id

    _.preq.put app.API.items.update, { ids, attribute, value }
    .tap propagateChange(items, attribute)
    .catch rollbackUpdate(items)

  destroy: (options)->
    # MUST: model with title
    # CAN: next
    { model, next, back } = options
    _.types [ model, next ], [ 'object', 'function' ]
    title = model.get('snapshot.entity:title')

    action = ->
      _.preq.delete app.API.items.delete(model.get('_id'))
      .tap ->
        app.user.trigger 'items:change', model.get('listing'), null
        model.isDestroyed = true
      .then next

    app.execute 'ask:confirmation',
      confirmationText: _.i18n 'delete_item_confirmation', { title }
      warningText: _.i18n 'cant_undo_warning'
      action: action
      back: back

propagateChange = (items, attribute)-> ->
  items.forEach (item)->
    # TODO: update counters for non-model items too
    if _.isString item then return
    if attribute is 'listing'
      { listing: previousListing } = item._backup
      newListing = item.get 'listing'
      if newListing is previousListing then return
      app.user.trigger 'items:change', previousListing, newListing
    delete item._backup

rollbackUpdate = (items)-> (err)->
  items.forEach (item)->
    if _.isString item then return
    item.set item._backup
    delete item._backup
  throw err
