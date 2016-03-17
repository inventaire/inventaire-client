module.exports = Backbone.Model.extend
  initialize: ->
    @set 'selected', true

  createItem: (transaction, listing)->
    [ title, isbn, authors ] = @gets 'title', 'isbn', 'authors'
    itemModel = app.request 'item:create',
      title: title
      entity: "isbn:#{isbn}"
      authors: authors
      transaction: transaction
      listing: listing

    # return a promise that waits for the item entity
    return itemModel.waitForEntity
    # before resolving to the item model
    .then -> itemModel
