wd_ = require 'lib/wikimedia/wikidata'
isbn_ = require 'lib/isbn'
entities_ = require '../lib/entities'
initializeWikidataEntity = require '../lib/wikidata/init_entity'
editableEntity = require '../lib/inv/editable_entity'
getBestLangValue = sharedLib('get_best_lang_value')(_)
initializeAuthor = require '../lib/types/author'
initializeSerie = require '../lib/types/serie'
initializeWork = require '../lib/types/work'
initializeEdition = require '../lib/types/edition'
error_ = require 'lib/error'

# One unique Entity model to rule them all
# but with specific initializers:
# - By source:
#   - Wikidata entities have specific initializers related to Wikimedia sitelinks
# - By type:
#   - Human (presumably an author)
#   - Work
#   - Edition

# Progressively extending the whitelist of editable types
editableTypes = [ 'work', 'edition', 'human', 'serie' ]

module.exports = Backbone.NestedModel.extend
  initialize: (attrs, options)->
    @refresh = options?.refresh
    @type = attrs.type or options.defaultType

    if @type is 'meta'
      # Set placeholder attributes so that the logic hereafter doesn't crash
      _.extend attrs, placeholderAttributes
      @set placeholderAttributes

    @setCommonAttributes attrs
    @listenForGraphChanges()

    # List of promises created from specialized initializers
    # to wait for before triggering @executeMetadataUpdate (see below)
    @_dataPromises = []
    if @wikidataId then initializeWikidataEntity.call @, attrs
    # For the moment, among local entities, only works are editable
    else if @type in editableTypes
      pathname = @get 'pathname'
      @set 'edit', "#{pathname}/edit"

    # If the entity isn't of any known type, it was probably fetched
    # for its label, there is thus no need to go further on initialization
    # as what follows is specific to core entities types
    # Or, it was fetched for its relation with an other entity but misses
    # the proper P31 data to display correctly. Then, when fetching the entity
    # a defaultType should be passed as option.
    # For instance, parts of a serie will default have a defaultType='work'
    unless @type then return

    if @get('edit')? then _.extend @, editableEntity

    # An object to store only the ids of such a relationship
    # ex: this entity is a P50 of entities Q...
    # /!\ Legacy: to be harmonized/merged with @subentities
    @set 'reverseClaims', {}

    switch @type
      when 'human' then initializeAuthor.call @
      when 'serie' then initializeSerie.call @
      when 'work' then initializeWork.call @
      when 'edition' then initializeEdition.call @
      when 'article' then null

    if @_dataPromises.length is 0 then @waitForData = _.preq.resolved
    else @waitForData = Promise.all @_dataPromises

  setCommonAttributes: (attrs)->
    unless attrs.claims?
      error_.report 'entity without claims', attrs
      attrs.claims = {}

    @wikidataId = attrs.claims['invp:P1']?[0]
    isbn13h = attrs.claims['wdt:P212']?[0]
    # Using de-hyphenated ISBNs for URIs
    if isbn13h? then @isbn = isbn_.normalizeIsbn isbn13h

    if @wikidataId
      uri = "wd:#{@wikidataId}"
      prefix = 'wd'
      @setAltUri()
    else if @isbn
      uri = "isbn:#{@isbn}"
      prefix = 'isbn'
      @setAltUri()
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

  setAltUri: ->
    invId = @get '_id'
    if invId? then @set 'altUri', "inv:#{invId}"

  fetchSubEntities: (refresh)->
    if not refresh and @waitForSubentities?
      return @waitForSubentities

    collection = @[@subentitiesName] = new Backbone.Collection

    uri = @get 'uri'
    prop = @childrenClaimProperty

    @hasSubentities = true

    @waitForSubentities = entities_.getReverseClaims prop, uri, refresh
    .tap @setSubEntitiesUris.bind(@)
    .then (uris)-> app.request 'get:entities:models', uris, refresh
    .then collection.add.bind(collection)

  setSubEntitiesUris: (uris)->
    @set 'subEntitiesUris', uris
    if @childrenInverseProperty then @set "claims.#{@childrenInverseProperty}", uris
    # The list of all uris that describe an entity that is this work or a subentity,
    # that is, an edition of this work
    @set 'allUris', [ @get('uri') ].concat(uris)

  # To be called by a view onShow:
  # updates the document with the entities data
  updateMetadata: ->
    @waitForData
    .then @executeMetadataUpdate.bind(@)
    .catch _.Error('updateMetadata err')

  executeMetadataUpdate: ->
    return Promise.props
      title: @buildTitleAsync()
      description: @findBestDescription()?[0..500]
      image: @getImageSrcAsync()
      url: @get 'pathname'

  findBestDescription: ->
    # So far, only Wikidata entities get extracts
    [ extract, description ] = @gets 'extract', 'description'
    # Dont use an extract too short as it will be
    # more of it's wikipedia source url than a description
    if extract?.length > 300 then return extract
    else return description or extract

  # Override in with type-specific methods
  buildTitle: -> @get 'label'
  buildTitleAsync: -> _.preq.resolve @buildTitle()
  getImageAsync: -> _.preq.resolve @get('image')
  getImageSrcAsync: ->
    @getImageAsync()
    .then (imageObj)->
      url = imageObj?.url
      if url? then return app.API.img(url)

  listenForGraphChanges: ->
    uri = @get 'uri'
    @listenTo app.vent, "entity:graph:change:#{uri}", @setRefreshToken.bind(@)

  setRefreshToken: -> @graphChanged = true
  getRefresh: (refresh)->
    refresh = refresh or @graphChanged
    # No need to force refresh until next graph change
    @graphChanged = false
    return refresh

placeholderAttributes =
  labels: {}
  aliases: {}
  descriptions: {}
  claims: {}
  sitelinks: {}
