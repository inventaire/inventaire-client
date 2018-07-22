error_ = require 'lib/error'
forms_ = require 'modules/general/lib/forms'

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
      .catch (err)=>
        err.selector = @alertBoxTarget
        # Let the time to the view to re-render after the model rolled back
        @setTimeout forms_.catchAlert.bind(null, @, err), 500

    itemDestroy: ->
      afterDestroy = @afterDestroy?.bind(@) or cb = -> console.log 'item deleted'
      itemDestroyBack = @itemDestroyBack?.bind(@)
      app.request 'item:destroy',
        model: @model
        selector: @uniqueSelector
        next: afterDestroy
        back: itemDestroyBack

  return
