module.exports =
  create: (itemData)->
    _.log itemData, 'item data before creation'

    _.preq.post app.API.items.base, itemData
    .then _.Log('item data after creation')

  update: (options)->
    # expects: item, attribute, value
    # OR expects: item, data
    # optional: selector
    { item, attribute, value, data, selector } = options
    _.types [item, selector], ['object', 'string|undefined']

    itemAttributesBefore = _.deepClone item.toJSON()

    if data?
      _.type data, 'object'
      item.set data
    else
      _.type attribute, 'string'
      item.set attribute, value

    item.save()
    .tap ->
      { listing:previousListing } = itemAttributesBefore
      app.user.trigger 'items:change', previousListing, item.get('listing')
    .catch rollbackUpdate(item, itemAttributesBefore)

  destroy: (options)->
    # MUST: selector, model with title
    # CAN: next
    { model, selector, next, back } = options
    _.types [model, selector, next], ['object', 'string', 'function']
    title = model.get('snapshot.entity:title')

    action = ->
      model.destroy()
      .tap -> app.user.trigger 'items:change', model.get('listing'), null
      .then next

    app.execute 'ask:confirmation',
      confirmationText: _.i18n 'destroy_item_text', { title }
      warningText: _.i18n "this action can't be undone"
      action: action
      back: back

rollbackUpdate = (item, itemAttributesBefore)-> (err)->
  item.set itemAttributesBefore
  throw err
