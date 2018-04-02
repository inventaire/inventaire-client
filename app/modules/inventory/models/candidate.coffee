isbn_ = require 'lib/isbn'

module.exports = Backbone.Model.extend
  # Use the normalized ISBN as id to deduplicate entries
  idAttribute: 'isbn'
  initialize: (attrs)->
    if attrs.isbn?
      unless attrs.rawIsbn?
        @set 'rawIsbn', attrs.isbn
      unless attrs.normalizedIsbn?
        @set 'normalizedIsbn', isbn_.normalizeIsbn(attrs.isbn)

    if attrs.isInvalid then return

    if not attrs.title?
      @set 'needInfo', true
    else
      @set 'selected', true

    @on 'change:title', @updateInfoState.bind(@)

  canBeSelected: -> not @get('isInvalid') and not @get('needInfo')

  updateInfoState: ->
    needInfo = not _.isNonEmptyString(@get('title'))
    @set 'needInfo', needInfo

  createItem: (transaction, listing)->
    app.request 'entity:exists:or:create:from:seed', @toJSON()
    .then (editionEntityModel)->
      return app.request 'item:create',
        entity: editionEntityModel.get 'uri'
        transaction: transaction
        listing: listing
