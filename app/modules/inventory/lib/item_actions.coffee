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

    ids = items.map getIdFromModelOrId

    _.preq.put app.API.items.update, { ids, attribute, value }
    .tap propagateChange(items, attribute)
    .catch rollbackUpdate(items)

  delete: (options)->
    { items, next, back } = options
    _.types [ items, next ], [ 'array', 'function' ]

    ids = items.map getIdFromModelOrId

    action = ->
      _.preq.post app.API.items.deleteByIds, { ids }
      .tap ->
        items.forEach (item)->
          if _.isString item then return
          app.user.trigger 'items:change', item.get('listing'), null
          item.isDestroyed = true
      .then next

    if items.length is 1 and items[0] instanceof Backbone.Model
      title = items[0].get 'snapshot.entity:title'
      confirmationText = _.i18n 'delete_item_confirmation', { title }
    else
      confirmationText = _.i18n 'delete_items_confirmation', { amount: ids.length }

    warningText = _.i18n 'cant_undo_warning'

    app.execute 'ask:confirmation', { confirmationText, warningText, action, back }

getIdFromModelOrId = (item)-> if _.isString item then item else item.id

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
