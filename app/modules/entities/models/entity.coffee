isbn_ = require 'lib/isbn'
entities_ = require '../lib/entities'
initializeWikidataEntity = require '../lib/wikidata/init_entity'
initializeInvEntity = require '../lib/inv/init_entity'
editableEntity = require '../lib/inv/editable_entity'
getBestLangValue = require 'modules/entities/lib/get_best_lang_value'
getOriginalLang = require 'modules/entities/lib/get_original_lang'
initializeAuthor = require '../lib/types/author'
initializeSerie = require '../lib/types/serie'
initializeWork = require '../lib/types/work'
initializeEdition = require '../lib/types/edition'
error_ = require 'lib/error'
Filterable = require 'modules/general/models/filterable'

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

placeholdersTypes = [ 'meta', 'missing' ]

module.exports = Filterable.extend
  initialize: (attrs, options)->
    @refresh = options?.refresh
    @type = attrs.type or options.defaultType

    if @type?
      @pluralizedType = @type + 's'

    if @type in placeholdersTypes
      # Set placeholder attributes so that the logic hereafter doesn't crash
      _.extend attrs, placeholderAttributes
      @set placeholderAttributes

    @setCommonAttributes attrs
    # Keep label updated
    @on 'change:labels', => @setFavoriteLabel @toJSON()

    @listenForGraphChanges()

    # List of promises created from specialized initializers
    # to wait for before triggering @executeMetadataUpdate (see below)
    @_dataPromises = []

    if @wikidataId then initializeWikidataEntity.call @, attrs
    else initializeInvEntity.call @, attrs

    if @type in editableTypes
      pathname = @get 'pathname'
      @set
        edit: "#{pathname}/edit"
        cleanup: "#{pathname}/cleanup"
        history: "#{pathname}/history"

    # If the entity isn't of any known type, it was probably fetched
    # for its label, there is thus no need to go further on initialization
    # as what follows is specific to core entities types
    # Or, it was fetched for its relation with an other entity but misses
    # the proper P31 data to display correctly. Then, when fetching the entity
    # a defaultType should be passed as option.
    # For instance, parts of a serie will default have a defaultType='work'
    unless @type
      # Placeholder
      @waitForData = Promise.resolved
      return

    if @get('edit')? then _.extend @, editableEntity

    # An object to store only the ids of such a relationship
    # ex: this entity is a P50 of entities Q...
    # /!\ Legacy: to be harmonized/merged with @subentities
    @set 'reverseClaims', {}

    @typeSpecificInit()

    if @_dataPromises.length is 0 then @waitForData = Promise.resolved
    else @waitForData = Promise.all @_dataPromises

  typeSpecificInit: ->
    switch @type
      when 'human' then initializeAuthor.call @
      when 'serie' then initializeSerie.call @
      when 'work' then initializeWork.call @
      when 'edition' then initializeEdition.call @
      when 'article' then null

  setCommonAttributes: (attrs)->
    unless attrs.claims?
      error_.report 'entity without claims', attrs
      attrs.claims = {}

    { uri } = attrs
    [ prefix, id ] = uri.split ':'

    if prefix is 'wd'
      @wikidataId = id
      @set 'isWikidataEntity', true

    isbn13h = attrs.claims['wdt:P212']?[0]
    # Using de-hyphenated ISBNs for URIs
    if isbn13h? then @isbn = isbn_.normalizeIsbn isbn13h

    if prefix isnt 'inv' then @setInvAltUri()

    pathname = "/entity/#{uri}"

    @set { prefix, pathname }
    @setFavoriteLabel attrs

  # Not naming it 'setLabel' as it collides with editable_entity own 'setLabel'
  setFavoriteLabel: (attrs)->
    @originalLang = getOriginalLang attrs.claims
    label = getBestLangValue(app.user.lang, @originalLang, attrs.labels).value
    @set 'label', label

  setInvAltUri: ->
    invId = @get '_id'
    if invId? then @set 'altUri', "inv:#{invId}"

  fetchSubEntities: (refresh)->
    if not refresh and @waitForSubentities? then return @waitForSubentities

    collection = @[@subentitiesName] = new Backbone.Collection

    # A draft entity can't already have subentities
    if @creating then return @waitForSubentities = Promise.resolved

    uri = @get 'uri'
    prop = @childrenClaimProperty

    @hasSubentities = true

    @waitForSubentities = entities_.getReverseClaims prop, uri, refresh
    .tap @setSubEntitiesUris.bind(@)
    .then (uris)-> app.request 'get:entities:models', { uris, refresh }
    .then @beforeSubEntitiesAdd.bind(@)
    .then collection.add.bind(collection)

  # Override in sub-types
  beforeSubEntitiesAdd: _.identity

  setSubEntitiesUris: (uris)->
    if @subEntitiesUrisFilter? then uris = uris.filter @subEntitiesUrisFilter

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
  buildTitleAsync: -> Promise.resolve @buildTitle()
  getImageAsync: -> Promise.resolve @get('image')
  getImageSrcAsync: ->
    @getImageAsync()
    # Let app/lib/metadata/apply_transformers format the URL with app.API.img
    .then (imageObj)-> imageObj?.url

  listenForGraphChanges: ->
    uri = @get 'uri'
    # Set a refresh token so that next time we need to access the entity's graph
    # we request a refreshed version
    @listenTo app.vent, "entity:graph:change:#{uri}", @setRefreshToken.bind(@)

  setRefreshToken: -> @graphChanged = true
  getRefresh: (refresh)->
    refresh = refresh or @graphChanged
    # No need to force refresh until next graph change
    @graphChanged = false
    return refresh

  matchable: ->
    { lang } = app.user
    userLangAliases = @get("aliases.#{lang}") or []
    return [ @get('label') ].concat userLangAliases

  # Overriden by modules/entities/lib/wikidata/init_entity.coffee
  # for Wikidata entities
  getWikipediaExtract: -> Promise.resolved

placeholderAttributes =
  labels: {}
  aliases: {}
  descriptions: {}
  claims: {}
  sitelinks: {}
