module.exports = Backbone.Model.extend
  initialize: ->
    @set 'selected', true

  createItem: (transaction, listing)->
    [ title, isbn ] = @gets 'title', 'isbn'
    itemModel = app.request 'item:create',
      title: title
      entity: "isbn:#{isbn}"
      transaction: transaction
      listing: listing

    itemModel._creationPromise
    # waits for the item entity
    .then -> itemModel.waitForEntity
    # before resolving to the item model
    .then -> itemModel
