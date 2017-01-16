module.exports =
  create: (itemData)->
    unless itemData.title? and itemData.title isnt ''
      throw new Error('cant create item: missing title')

    # will be confirmed by the server
    itemData.owner = app.user.id

    itemModel = app.items.add itemData

    itemModel._creationPromise = itemModel.save()
      .then _.Log('item creation server res')
      .then itemModel.onCreation.bind(itemModel)
      .then -> return itemModel
      .catch _.ErrorRethrow('item creation err')

    return itemModel

  update: (options)->
    # expects: item, attribute, value
    # OR expects: item, data
    # optional: selector
    { item, attribute, value, data, selector } = options
    _.types [item, selector], ['object', 'string|undefined']

    if data?
      _.type data, 'object'
      item.set data
    else
      _.type attribute, 'string'
      item.set attribute, value

    promise = item.save()
    if selector?
      app.request 'waitForCheck',
        promise: promise
        selector: selector
    return promise

  destroy: (options)->
    # requires the ConfirmationModal behavior to be on the view
    # MUST: selector, model with title
    # CAN: next
    { model, selector, next } = options
    _.types [model, selector, next], ['object', 'string', 'function']
    title = model.get('title')

    action = -> model.destroy().then next

    $(selector).trigger 'askConfirmation',
      confirmationText: _.i18n('destroy_item_text', {title: title})
      warningText: _.i18n("this action can't be undone")
      action: action
