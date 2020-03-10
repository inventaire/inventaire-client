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
    @getEntityModel()
    .then (editionEntityModel)->
      return app.request 'item:create',
        entity: editionEntityModel.get 'uri'
        transaction: transaction
        listing: listing

  getEntityModel: ->
    # Always return a promise
    Promise.try =>
      if @get('uri')? then return @
      entry = @serializeResolverEntry()
      return app.request 'entity:exists:or:create:from:seed', entry

  serializeResolverEntry: ->
    data = @toJSON()
    { isbn, title, lang, authors: authorsNames, normalizedIsbn, publicationDate, numberOfPages } = data

    edition =
      isbn: isbn or normalizedIsbn
      claims:
        'wdt:P1476': [ title ]

    if publicationDate? then edition.claims['wdt:P577'] = publicationDate
    if numberOfPages? then edition.claims['wdt:P1104'] = numberOfPages

    authors = _.forceArray(authorsNames).map (name)->
      labelLang = lang or app.user.lang
      labels = { "#{labelLang}": name }
      return { labels }

    return { edition, authors }
