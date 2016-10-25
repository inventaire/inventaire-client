wd_ = require 'lib/wikimedia/wikidata'
isbn_ = require 'lib/isbn'
entities_ = require '../lib/entities'
initializeWikidataEntity = require '../lib/wikidata/init_entity'
editableEntity = require '../lib/inv/editable_entity'
getBestLangValue = require '../lib/get_best_lang_value'
initializeBook = require '../lib/types/book'
initializeSerie = require '../lib/types/serie'
initializeAuthor = require '../lib/types/author'

# One unique Entity model to rule them all
# but with specific initializers:
# - By source:
#   - Wikidata entities have specific initializers related to Wikimedia sitelinks
# - By type:
#   - Human (presumably an author)
#   - Book
#   - Edition

module.exports = Backbone.NestedModel.extend
  initialize: (attrs)->
    @refresh = options?.refresh
    @type = attrs.type

    # If the entity isn't of any known type, it was probably fetched
    # for its label, there is thus no need to go further on initialization
    unless @type then return

    @setCommonAttributes attrs

    # List of promises created from specialized initializers
    # to wait for before triggering @executeMetadataUpdate (see below)
    @_dataPromises = []
    if @wikidataId then initializeWikidataEntity.call @, attrs
    _.extend @, editableEntity

    # An object to store references to subentities collections
    # ex: @subentities['wdt:P629'] = thisBookEditionsCollection
    @subentities = {}
    # An object to store only the ids of such a relationship
    # ex: this entity is a P50 of entities Q...
    # /!\ Legacy: to be harmonized/merged with @subentities
    @set 'reverseClaims', {}

    switch @type
      when 'serie' then initializeSerie.call @
      when 'book' then initializeBook.call @
      when 'human' then initializeAuthor.call @
      when 'article', 'edition' then null
      # when 'edition' then @initializeEdition()

    if @_dataPromises.length is 0 then @waitForData = _.preq.resolved
    else @waitForData = Promise.all @_dataPromises

  setCommonAttributes: (attrs)->
    @wikidataId = attrs.claims['invp:P1']?[0]
    isbn13h = attrs.claims['wdt:P212']?[0]
    # Using de-hyphenated ISBNs for URIs
    if isbn13h? then @isbn = isbn_.normalizeIsbn isbn13h

    if @wikidataId
      uri = "wd:#{@wikidataId}"
      prefix = 'wd'
    else if @isbn
      uri = "isbn:#{@isbn}"
      prefix = 'isbn'
    else
      uri = "inv:#{attrs._id}"
      prefix = 'inv'

    pathname = "/entity/#{uri}"

    @originalLang = wd_.getOriginalLang attrs.claims
    label = getBestLangValue app.user.lang, @originalLang, attrs.labels

    @set
      uri: uri
      prefix: prefix
      pathname: pathname
      label: label
      editable:
        wiki: "#{pathname}/edit"

  fetchSubEntities: (refresh)->
    if not refresh and @waitForSubentities?
      return @waitForSubentities

    @subentities = new Backbone.Collection

    uri = @get 'uri'
    prop = @childrenClaimProperty

    @waitForSubentities = entities_.getReverseClaims prop, uri, refresh
    .then (uris)-> app.request 'get:entities:models', uris, refresh
    .then @subentities.add.bind(@subentities)

  # To be called by a view onShow:
  # updates the document with the entities data
  updateMetadata: ->
    @waitForData
    .then @executeMetadataUpdate.bind(@)
    .catch _.Error('updateMetadata err')

  executeMetadataUpdate: ->
    app.execute 'metadata:update',
      title: @buildTitle()
      description: @findBestDescription()?[0..500]
      image: @get('images.url')
      url: @get 'pathname'

  findBestDescription: ->
    # So far, only Wikidata entities get extracts
    [ extract, description ] = @gets 'extract', 'description'
    # Dont use an extract too short as it will be
    # more of it's wikipedia source url than a description
    if extract?.length > 300 then return extract
    else return description or extract

  buildTitle: ->
    title = @get 'label'
    switch @type
      when 'human' then _.i18n 'books_by_author', { author: title }
      when 'book', 'edition' then @buildBookTitle @type
      else title
