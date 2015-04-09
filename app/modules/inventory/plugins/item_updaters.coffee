module.exports = ->
  _.extend @events,
    'click a.user': 'showUser'
    'click a.remove': 'itemDestroy'
    'click a.transaction': 'updateTransaction'
    'click a.listing': 'updateListing'
    'click a.requestItem': 'requestItem'

  _.extend @,
    updateTransaction: (e)->
      @updateItem 'transaction', e.target.id

    updateListing: (e)->
      @updateItem 'listing', e.target.id

    updateItem: (attribute, value)->
      app.request 'item:update',
        item: @model
        attribute: attribute
        value: value

  return