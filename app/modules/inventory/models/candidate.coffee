module.exports = Backbone.Model.extend
  # Use the normalized ISBN as id to deduplicate entries
  idAttribute: 'isbn'
  initialize: (attrs)->
    if not attrs.isValid then return

    if not attrs.title?
      @set 'needInfo', true
    else
      @set 'selected', true

    @on 'change', @updateState.bind(@)

  updateState: ->
    needInfo = not _.isNonEmptyString(@get('title'))
    @set 'needInfo', needInfo

  createItem: (transaction, listing)->
    app.request 'entity:exists:or:create:from:seed', @toJSON()
    .then (editionEntityModel)->
      return app.request 'item:create',
        entity: editionEntityModel.get 'uri'
        transaction: transaction
        listing: listing
