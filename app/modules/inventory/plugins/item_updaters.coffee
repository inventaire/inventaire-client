error_ = require 'lib/error'

module.exports = ->
  _.extend @events,
    'click a.transaction': 'updateTransaction'
    'click a.listing': 'updateListing'
    'click a.remove': 'itemDestroy'

  _.extend @,
    updateTransaction: (e)->
      @updateItem 'transaction', e.target.id

    updateListing: (e)->
      @updateItem 'listing', e.target.id

    updateItem: (attribute, value)->
      unless attribute? and value?
        return _.preq.reject error_.new('invalid item update', arguments)

      app.request 'item:update',
        item: @model
        attribute: attribute
        value: value

    itemDestroy: ->
      afterDestroy = @afterDestroy or cb = -> console.log 'item deleted'
      app.request 'item:destroy',
        model: @model
        selector: @uniqueSelector
        next: afterDestroy

  return
