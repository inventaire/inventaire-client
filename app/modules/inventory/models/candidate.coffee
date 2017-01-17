module.exports = Backbone.Model.extend
  initialize: ->
    @set 'selected', true

  createItem: (transaction, listing)->
    title = @get 'title'

    app.request 'entity:exists:or:create:from:seed', @toJSON()
    .then (editionEntityModel)->
      itemModel = app.request 'item:create',
        title: title
        entity: editionEntityModel.get 'uri'
        transaction: transaction
        listing: listing

      return itemModel._creationPromise
