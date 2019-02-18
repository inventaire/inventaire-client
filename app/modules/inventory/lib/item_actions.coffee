Item = require 'modules/inventory/models/item'

module.exports =
  create: (itemData)->
    _.log itemData, 'item data before creation'

    _.preq.post app.API.items.base, itemData
    .then _.Log('item data after creation')
    .then (data)-> new Item data

  update: (options)->
    # expects: item, attribute, value
    # OR expects: item, data
    # optional: selector
    { item, attribute, value, data, selector } = options
    _.types [ item, selector ], [ 'object', 'string|undefined' ]

    itemAttributesBefore = _.deepClone item.toJSON()

    if data?
      _.type data, 'object'
      item.set data
    else
      _.type attribute, 'string'
      item.set attribute, value

    _.preq.put app.API.items.update,
      ids: [ item.id ]
      attribute: attribute
      value: value
    .tap ->
      { listing:previousListing } = itemAttributesBefore
      app.user.trigger 'items:change', previousListing, item.get('listing')
    .catch rollbackUpdate(item, itemAttributesBefore)

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

rollbackUpdate = (item, itemAttributesBefore)-> (err)->
  item.set itemAttributesBefore
  throw err
