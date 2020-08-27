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

    if not @get('uri') and @get('normalizedIsbn')?
      @set 'uri', "isbn:#{@get('normalizedIsbn')}"

    if attrs.isInvalid then return

    @setStatusData()

    @on 'change:title', @updateInfoState.bind(@)

  canBeSelected: -> not @get('isInvalid') and not @get('needInfo')

  updateInfoState: ->
    needInfo = not _.isNonEmptyString(@get('title'))
    @set 'needInfo', needInfo

  setStatusData: ->
    existingEntityItemsCount = @get 'existingEntityItemsCount'
    if existingEntityItemsCount? and existingEntityItemsCount > 0
      uri = @get 'uri'
      username = app.user.get 'username'
      @set 'existingEntityItemsPathname', "/inventory/#{username}/#{uri}"
    else if not @get('title')?
      @set 'needInfo', true
    else
      @set 'selected', true

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
      # Duck typing an entity model
      if @get('claims')? then return @
      entry = @serializeResolverEntry()
      return app.request 'entity:exists:or:create:from:seed', entry

  serializeResolverEntry: ->
    data = @toJSON()
    { isbn, title, lang, authors: authorsNames, normalizedIsbn } = data
    labelLang = lang or app.user.lang

    edition =
      isbn: isbn or normalizedIsbn
      claims:
        'wdt:P1476': [ title ]

    work = { labels: {}, claims: {} }
    work.labels[labelLang] = title

    if data.publicationDate? then edition.claims['wdt:P577'] = data.publicationDate
    if data.numberOfPages? then edition.claims['wdt:P1104'] = data.numberOfPages
    if data.goodReadsEditionId? then edition.claims['wdt:P2969'] = data.goodReadsEditionId

    if data.libraryThingWorkId? then work.claims['wdt:P1085'] = data.libraryThingWorkId

    authors = _.forceArray(authorsNames).map (name)->
      labels = { "#{labelLang}": name }
      return { labels }

    return { edition, works: [ work ], authors }
