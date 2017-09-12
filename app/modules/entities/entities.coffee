isbn_ = require 'lib/isbn'
wd_ = require 'lib/wikimedia/wikidata'
wdk = require 'lib/wikidata-sdk'
Entity = require './models/entity'
Entities = require './collections/entities'
AuthorLayout = require './views/author_layout'
SerieLayout = require './views/serie_layout'
WorkLayout = require './views/work_layout'
EditionLayout = require './views/edition_layout'
EntityEdit = require './views/editor/entity_edit'
GenreLayout= require './views/genre_layout'
error_ = require 'lib/error'
createEntities = require './lib/create_entities'
entityDraftModel = require './lib/entity_draft_model'
entitiesModelsIndex = require './lib/entities_models_index'
createInvEntity = require './lib/inv/create_inv_entity'
ChangesLayout = require './views/changes_layout'
ActivityLayout = require './views/activity_layout'
DeduplicateLayout = require './views/deduplicate_layout'
WikidataEditIntro = require './views/wikidata_edit_intro'
MergeSuggestions = require './views/editor/merge_suggestions'
Works = require './collections/works'
WorksList = require './views/works_list'
{ entity:entityValueTemplate } = require 'lib/handlebars_helpers/claims_helpers'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'entity/new': 'showEntityCreateFromRoute'
        'entity/changes': 'showChanges'
        'entity/activity': 'showActivity'
        'entity/deduplicate': 'showDeduplicate'
        'entity/:uri/deduplicate(/)': 'showEntityDeduplicate'
        'entity/:uri(/:label)/add(/)': 'showAddEntity'
        'entity/:uri(/:label)/edit(/)': 'showEditEntityFromUri'
        'entity/:uri(/:label)(/)': 'showEntity'
        'wd/:qid': 'showWdEntity'
        'isbn/:isbn': 'showIsbnEntity'
        'inv/:id': 'showInvEntity'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    setHandlers()

API =
  showEntity: (uri, label, params)->
    if isClaim uri then return showClaimEntities uri, params

    uri = normalizeUri uri
    unless _.isExtendedEntityUri uri then return app.execute 'show:error:missing'

    app.execute 'show:loader', { region: app.layout.main }

    refresh = params?.refresh or app.request('querystring:get', 'refresh')
    if refresh then app.execute 'uriLabel:refresh'

    getEntityModel uri, refresh
    .then (entity)->
      if entity.type? then return entity
      else throw error_.new 'unknown entity type', 400, entity
    .tap app.navigateFromModel
    .then @getEntityViewByType.bind(@, refresh)
    .then app.layout.main.show.bind(app.layout.main)
    .catch handleMissingEntity(uri)

  getEntityViewByType: (refresh, entity)->
    getter = entityViewGetterByType[entity.type]
    if getter? then @[getter](entity, refresh)
    else throw error_.new 'invalid entity type', entity

  getAuthorView: (entity, refresh)->
    new AuthorLayout
      model: entity
      standalone: true
      initialLength: 20
      refresh: refresh

  getSerieView: (model, refresh)->
    new SerieLayout { model, refresh, standalone: true }

  getWorkView: (model, refresh)-> new WorkLayout { model, refresh }

  getWorkViewFromEdition: (model, refresh)->
    new EditionLayout { model, refresh, standalone: true }

  getGenreLayout: (model, refresh)-> new GenreLayout { model, refresh }

  showAddEntity: (uri)->
    getEntityModel uri
    .then (entity)->
      app.execute 'show:item:creation:form',
        entity: entity
        preventduplicates: true

    .catch handleMissingEntity(uri)

  showEditEntityFromUri: (uri)->
    # Make sure we have the freshest data before trying to edit
    getEntityModel uri, true
    .then showEntityEditFromModel
    .catch handleMissingEntity(uri)

  showEntityCreateFromRoute: ->
    if app.request 'require:loggedIn', 'entity/new'
      showEntityCreate app.request('querystring:get:full')

  showWdEntity: (qid)-> API.showEntity "wd:#{qid}"
  showIsbnEntity: (isbn)-> API.showEntity "isbn:#{isbn}"
  showInvEntity: (id)-> API.showEntity "inv:#{id}"
  showChanges: ->
    app.layout.main.show new ChangesLayout
    app.navigate 'entity/changes', { metadata: { title: 'changes' } }

  showActivity: ->
    showViewWithAdminRights 'entity/activity', 'activity', ActivityLayout

  showDeduplicate: ->
    showViewWithAdminRights 'entity/deduplicate', 'deduplicate', DeduplicateLayout

  showEntityDeduplicate: (uri)->
    getEntityModel uri
    .then (entity)->
      showMergeSuggestions
        region: app.layout.main
        model: entity
        standalone: true

showEntityCreate = (params)->
  # Default to an entity of type work
  # so that /entity/new doesn't just return an error
  params.type or= 'work'

  { type } = params
  unless type in entityDraftModel.whitelistedTypes
    err = error_.new "invalid entity draft type: #{type}", params
    return app.execute 'show:error:other', err

  params.model = entityDraftModel.create params
  showEntityEdit params

setHandlers = ->
  app.commands.setHandlers
    'show:entity': API.showEntity.bind(API)

    'show:entity:from:model': (model, params)->
      uri = model.get('uri')
      if uri? then app.execute 'show:entity', uri, null, params
      else throw new Error "couldn't show:entity:from:model"

    'show:entity:refresh': (model)->
      app.execute 'show:entity:from:model', model, { refresh: true }

    'show:entity:add': API.showAddEntity.bind API
    'show:entity:add:from:model': (model)-> API.showAddEntity model.get('uri')
    'show:entity:edit': API.showEditEntityFromUri
    'show:entity:edit:from:model': (model)->
      # Uses API.showEditEntityFromUri the fetch fresh entity data
      API.showEditEntityFromUri model.get('uri')
    'show:entity:create': showEntityCreate
    'show:work:with:item:modal': showWorkWithItemModal
    'show:merge:suggestions': showMergeSuggestions

  app.reqres.setHandlers
    'get:entity:model': getEntityModel
    'get:entities:models': getEntitiesModels
    'create:entity': createEntity
    'get:entity:local:href': getEntityLocalHref
    'entity:exists:or:create:from:seed': existsOrCreateFromSeed

getEntitiesModels = (params)->
  { uris, refresh, defaultType, index } = params
  _.type uris, 'array'
  _.types uris, 'strings...'
  # Make sure its a 'true' flag and not an object incidently passed
  refresh = refresh is true

  if uris.length is 0 then return _.preq.resolve []

  entitiesModelsIndex.get { uris, refresh, defaultType }
  # Do not return entities with type 'missing'.
  # This type is used to avoid re-fetching an entity already known to be missing
  # but has no interest past entitiesModelsIndex
  .then (models)->
    if index then models
    else _.values(models).filter isntMissing

# Known case of model being undefined: when the model initialization failed
isntMissing = (model)-> model? and model?.type isnt 'missing'

getEntityModel = (uri, refresh)->
  getEntitiesModels { uris: [ uri ], refresh }
  .then (models)->
    model = models[0]
    if model?
      return model
    else
      # see getEntitiesModels "Possible reasons for missing entities"
      _.log "getEntityModel entity_not_found: #{uri}"
      throw error_.new 'entity_not_found', [ uri, models ]

createEntity = (data)->
  createInvEntity data
  .then entitiesModelsIndex.add

getEntityLocalHref = (uri)-> "/entity/#{uri}"

showEntityEdit = (params)->
  { model } = params
  unless model.type? then throw error_.new 'invalid entity type', model
  app.layout.main.show new EntityEdit(params)
  app.navigateFromModel model, 'edit'

showEntityEditFromModel = (model)->
  prefix = model.get 'prefix'
  if prefix is 'wd' and not app.user.hasWikidataOauthTokens()
    showWikidataEditIntroModal model
  else
    showEntityEdit { model }

showWikidataEditIntroModal = (model)->
  app.layout.modal.show new WikidataEditIntro { model }

handleMissingEntity = (uri)-> (err)->
  switch err.message
    when 'invalid entity type'
      app.execute 'show:error:other', err
    when 'entity_not_found'
      [ prefix, id ] = uri.split ':'
      if prefix is 'isbn' then showEntityCreateFromIsbn id
      else app.execute 'show:error:missing'
    else
      app.execute 'show:error:other', err, 'handleMissingEntity'

showEntityCreateFromIsbn = (isbn)->
  _.preq.get app.API.data.isbn(isbn)
  .then (isbnData)->
    { isbn13h, groupLangUri } = isbnData
    claims = { 'wdt:P212': [ isbn13h ] }
    # TODO: try to deduce publisher from ISBN publisher section
    if _.isEntityUri groupLangUri then claims['wdt:P407'] = [ groupLangUri ]

    # Start by requesting the creation of a work entity
    showEntityCreate
      header: 'new-work-and-edition'
      type: 'work'
      # on which will be based an edition entity
      next:
        # The work entity should be used as 'edition of' value
        relation: 'wdt:P629'
        # The work label should be used as edition title suggestion
        labelTransfer: 'wdt:P1476'
        type: 'edition'
        claims: claims

  # Known case: when passed an invalid ISBN
  .catch (err)-> app.execute 'show:error:other', err, 'showEntityCreateFromIsbn'

normalizeUri = (uri)->
  [ prefix, id ] = uri.split ':'
  if not id?
    if wdk.isWikidataItemId prefix then [ prefix, id ] = [ 'wd', prefix ]
    else if _.isInvEntityId prefix then [ prefix, id ] = [ 'inv', prefix ]
    else if isbn_.looksLikeAnIsbn prefix
      [ prefix, id ] = [ 'isbn', isbn_.normalizeIsbn(prefix) ]
  else
    if prefix is 'isbn' then id = isbn_.normalizeIsbn id

  return "#{prefix}:#{id}"

# Create from the seed data we have, if the entity isn't known yet
existsOrCreateFromSeed = (data)->
  _.preq.post app.API.entities.existsOrCreateFromSeed, data
  # Add the possibly newly created edition entity to the local index
  # and get it's model
  .then entitiesModelsIndex.add

showWorkWithItemModal = (item)->
  getWorkEntity item.get('entity')
  .then _showWorkWithItem(item)

getWorkEntity = (uri)->
  getEntityModel uri
  .then (entity)->
    if entity.type is 'work'
      return entity
    else
      workUri = entity.get 'claims.wdt:P629.0'
      return getEntityModel workUri

_showWorkWithItem = (item)-> (work)->
  { currentView } = app.layout.main
  if currentView instanceof WorkLayout and currentView.model is work
    currentView.showItemModal item
    # Do not scroll top as the modal might be displayed down at the level
    # where the item show event was triggered
    app.navigateFromModel item, { preventScrollTop: true }
  else
    app.layout.main.show new WorkLayout { model: work, item }
    app.navigateFromModel item

showViewWithAdminRights = (path, title, View)->
  if app.request 'require:loggedIn', path
    app.navigate path, { metadata: { title } }
    if app.request 'require:admin:rights' then app.layout.main.show new View

showMergeSuggestions = (params)->
  { region, model } = params
  { pluralizedType } = model
  uri = model.get 'uri'
  _.preq.get app.API.entities.search model.get('label'), false, true
  .get pluralizedType
  .then parseSearchResults(uri)
  .then (suggestions)->
    collection = new Entities suggestions
    toEntity = model
    region.show new MergeSuggestions { collection, toEntity }

parseSearchResults = (uri)-> (searchResults)->
  uris = _.pluck searchResults, 'uri'
  prefix = uri.split(':')[0]
  if prefix is 'wd' then uris = uris.filter isntWdUri
  # Omit the current entity URI
  uris = _.without uris, uri
  # Search results entities miss their claims, so we need to fetch the full entities
  return app.request 'get:entities:models', { uris }

isntWdUri = (uri)-> uri.split(':')[0] isnt 'wd'

entityViewGetterByType =
  human: 'getAuthorView'
  serie: 'getSerieView'
  work: 'getWorkView'
  edition: 'getWorkViewFromEdition'
  genre: 'getGenreLayout'

isClaim = (claim)-> /^(wdt:|invp:)/.test claim
showClaimEntities = (claim, params)->
  [ property, value ] = claim.split('-')

  unless _.isPropertyUri property
    error_.report 'invalid property'
    return app.execute 'show:error:missing'

  unless _.isExtendedEntityUri value
    error_.report 'invalid value'
    return app.execute 'show:error:missing'

  # TODO: use a more strict request to get only entities from whitelisted types
  # (and not things like films, songs, etc)
  _.preq.get app.API.entities.reverseClaims(property, value)
  .get 'uris'
  .then _.Log('URIs')
  .then (uris)->
    collection = new Works null, { uris: uris, defaultType: 'work' }

    # whitelisted properties labels are in i18n keys already, thus should not need
    # to be fetched like what 'entityValueTemplate' is doing for the entity value
    propertyValue = _.i18n wd_.unprefixify(property)
    entityValue = entityValueTemplate value

    app.layout.main.show new WorksList {
      title: "#{propertyValue}: #{entityValue}"
      customTitle: true
      collection: collection
      canAddOne: false
      standalone: true
    }
