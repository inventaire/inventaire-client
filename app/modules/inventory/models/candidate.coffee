module.exports = Backbone.Model.extend
  initialize: ->
    @set 'selected', true

  createItem: (transaction, listing)->
    [ title, isbn, authors ] = @gets 'title', 'isbn', 'authors'

    app.request 'entity:exists:or:create:from:seed', { title, isbn, authors }
    .then (editionEntityModel)->
      itemModel = app.request 'item:create',
        title: title
        entity: editionEntityModel.get 'uri'
        transaction: transaction
        listing: listing

      return itemModel._creationPromise
