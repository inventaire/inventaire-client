module.exports = Backbone.Model.extend
  initialize: ->
    @set 'selected', true

  createItem: (transaction, listing)->
    app.request 'entity:exists:or:create:from:seed', @toJSON()
    .then (editionEntityModel)->
      return app.request 'item:create',
        entity: editionEntityModel.get 'uri'
        transaction: transaction
        listing: listing
