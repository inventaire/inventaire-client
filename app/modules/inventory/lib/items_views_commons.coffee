error_ = require 'lib/error'
forms_ = require 'modules/general/lib/forms'

module.exports =
  itemShow: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:item', @model

  showUser: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:user', @model
      # Required to close the ItemShow modal if one was open
      app.execute 'modal:close'

  showTransaction: (e)->
    unless _.isOpenedOutside e
      transac = app.request 'get:transaction:ongoing:byItemId', @model.id
      app.execute 'show:transaction', transac.id
      # Required to close the ItemShow modal if one was open
      app.execute 'modal:close'

  updateTransaction: (e)->
    @updateItem 'transaction', e.target.id

  updateListing: (e)->
    @updateItem 'listing', e.target.id

  updateItem: (attribute, value)->
    unless attribute? and value?
      return error_.reject 'invalid item update', arguments

    app.request 'items:update',
      items: [ @model ]
      attribute: attribute
      value: value
    .catch (err)=>
      err.selector = @alertBoxTarget
      # Let the time to the view to re-render after the model rolled back
      @setTimeout forms_.catchAlert.bind(null, @, err), 500

  itemDestroy: ->
    afterDestroy = @afterDestroy?.bind(@) or cb = -> console.log 'item deleted'
    itemDestroyBack = @itemDestroyBack?.bind(@)
    app.request 'items:delete',
      items: [ @model ]
      next: afterDestroy
      back: itemDestroyBack
