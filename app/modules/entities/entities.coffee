isbn_ = require 'lib/isbn'
wdk = require 'lib/wikidata-sdk'
Entity = require './models/entity'
AuthorLayout = require './views/author_layout'
SerieLayout = require './views/serie_layout'
SerieCleanup = require './views/cleanup/serie_cleanup'
WorkLayout = require './views/work_layout'
ArticleLi = require './views/article_li'
EditionLayout = require './views/edition_layout'
EntityEdit = require './views/editor/entity_edit'
EntityCreate = require './views/editor/entity_create'
MultiEntityEdit = require './views/editor/multi_entity_edit'
GenreLayout = require './views/genre_layout'
PublisherLayout = require './views/publisher_layout'
error_ = require 'lib/error'
entityDraftModel = require './lib/entity_draft_model'
entitiesModelsIndex = require './lib/entities_models_index'
createInvEntity = require './lib/inv/create_inv_entity'
ChangesLayout = require './views/changes_layout'
ActivityLayout = require './views/activity_layout'
ClaimLayout = require './views/claim_layout'
DeduplicateLayout = require './views/deduplicate_layout'
WikidataEditIntro = require './views/wikidata_edit_intro'
History = require './views/editor/history'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'entity/new(/)': 'showEntityCreateFromRoute'
        'entity/changes(/)': 'showChanges'
        'entity/activity(/)': 'showActivity'
        'entity/deduplicate(/)': 'showDeduplicate'
        'entity/:uri/add(/)': 'showAddEntity'
        'entity/:uri/edit(/)': 'showEditEntityFromUri'
        'entity/:uri/cleanup(/)': 'showEntityCleanup'
        'entity/:uri/deduplicate(/)': 'showEntityDeduplicate'
        'entity/:uri/history(/)': 'showEntityHistory'
        'entity/:uri(/)': 'showEntity'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    setHandlers()

API =
  showEntity: (uri, params)->
    refresh = params?.refresh or app.request('querystring:get', 'refresh')
    if isClaim uri then return showClaimEntities uri, refresh

    uri = normalizeUri uri
    unless _.isExtendedEntityUri uri then return app.execute 'show:error:missing'

    app.execute 'show:loader'

    if refresh then app.execute 'uriLabel:refresh'

    getEntityModel uri, refresh
    .then (entity)->
      if entity.get('_meta_type') is 'removed:placeholder'
        throw error_.new 'removed placeholder', 400, { entity }
      else if entity.type? then return entity
      else throw error_.new 'unknown entity type', 400, entity
    .tap app.navigateFromModel
    .then @getEntityViewByType.bind(@, refresh)
    .then app.layout.main.show.bind(app.layout.main)
    .catch (err)->
      # Redirect unknown entity types to their subject pages
      if err.message is 'unknown entity type'
        return showClaimEntities "wdt:P921-#{uri}"
      else
        throw err
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

  getArticleView: (model)-> new ArticleLi { model }

  # WorkLayout is only used in standalone mode, but the flag is required by ./lib/entity_items
  getWorkView: (model, refresh)-> new WorkLayout { model, refresh, standalone: true }

  getEditionView: (model, refresh)->
    model.waitForWorks
    .then -> new EditionLayout { model, refresh, standalone: true }

  getGenreLayout: (model, refresh)-> new GenreLayout { model, refresh }

  getPublisherLayout: (model, refresh)-> new PublisherLayout { model, refresh }

  showAddEntity: (uri)->
    uri = normalizeUri uri
    getEntityModel uri
    .then (entity)->
      app.execute 'show:item:creation:form',
        entity: entity
        preventduplicates: true

    .catch handleMissingEntity(uri)

  showEditEntityFromUri: (uri)->
    app.execute 'show:loader'
    uri = normalizeUri uri

    # Make sure we have the freshest data before trying to edit
    getEntityModel uri, true
    .then showEntityEditFromModel
    .catch handleMissingEntity(uri)

  showEntityCreateFromRoute: ->
    if app.request 'require:loggedIn', 'entity/new'
      showEntityCreate app.request('querystring:get:full')

  showChanges: ->
    app.layout.main.show new ChangesLayout
    app.navigate 'entity/changes', { metadata: { title: 'changes' } }

  showActivity: ->
    showViewWithAdminRights
      path: 'entity/activity'
      title: 'activity'
      View: ActivityLayout

  showDeduplicate: (params = {})->
    # Using an object interface, as the router might pass querystrings
    { uris } = params
    uris = _.forceArray uris
    showViewWithAdminRights
      path: 'entity/deduplicate'
      title: 'deduplicate'
      View: DeduplicateLayout
      viewOptions: { uris }
      # Assume that if uris are passed, navigate was already done
      # to avoid double navigation
      navigate: not uris?

  showEntityCleanup: (uri)->
    if app.request 'require:loggedIn', "entity/#{uri}/cleanup"
      app.execute 'show:loader'
      uri = normalizeUri uri

      getEntityModel uri, true
      .then showEntityCleanupFromModel
      .catch handleMissingEntity(uri)

  showEntityDeduplicate: (uri)->
    unless app.request 'require:loggedIn', "entity/#{uri}/deduplicate" then return
    unless app.request 'require:admin:rights' then return

    getEntityModel uri, true
    .then (model)->
      app.execute 'show:merge:suggestions', { model, region: app.layout.main, standalone: true }

  showEntityHistory: (uri)->
    unless app.request 'require:loggedIn', "entity/#{uri}/history" then return
    unless app.request 'require:admin:rights' then return

    uri = normalizeUri uri

    getEntityModel uri
    .then (model)->
      model.fetchHistory()
      .then ->
        app.layout.main.show new History { model, standalone: true }
        app.navigateFromModel model, 'history'
    .catch app.Execute('show:error')

showEntityCreate = (params)->
  { type } = params
  if type? and type not in entityDraftModel.whitelistedTypes
    err = error_.new "invalid entity draft type: #{type}", params
    return app.execute 'show:error:other', err

  if type?
    params.model = entityDraftModel.create params
    showEntityEdit params
  else
    app.layout.main.show new EntityCreate(params)

setHandlers = ->
  app.commands.setHandlers
    'show:entity': API.showEntity.bind(API)
    'show:claim:entities': (property, value)->
      claim = "#{property}-#{value}"
      API.showEntity claim
      app.navigate "entity/#{claim}"

    'show:entity:from:model': (model, params)->
      uri = model.get('uri')
      if uri? then app.execute 'show:entity', uri, params
      else throw new Error "couldn't show:entity:from:model"

    'show:entity:refresh': (model)->
      app.execute 'show:entity:from:model', model, { refresh: true }

    'show:deduplicate:sub:entities': (model, options = {})->
      { openInNewTab } = options
      uri = model.get 'uri'
      pathname = '/entity/deduplicate?uris=' + uri
      if openInNewTab
        window.open pathname, '_blank'
      else
        API.showDeduplicate { uris: [ uri ] }
        app.navigate pathname

    'show:entity:add': API.showAddEntity.bind API
    'show:entity:add:from:model': (model)-> API.showAddEntity model.get('uri')
    'show:entity:edit': API.showEditEntityFromUri
    'show:entity:edit:from:model': (model)->
      # Uses API.showEditEntityFromUri the fetch fresh entity data
      API.showEditEntityFromUri model.get('uri')
    'show:entity:edit:from:params': showEntityEdit
    'show:entity:create': showEntityCreate
    'show:entity:cleanup': API.showEntityCleanup
    'show:work:with:item:modal': showWorkWithItemModal
    'show:merge:suggestions': require './lib/show_merge_suggestions'
    'report:entity:type:issue': reportTypeIssue
    'show:wikidata:edit:intro:modal': showWikidataEditIntroModal

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

  if uris.length is 0 then return Promise.resolve []

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
  { model, region } = params
  unless model.type? then throw error_.new 'invalid entity type', model
  View = if params.next? or params.previous? then MultiEntityEdit else EntityEdit
  region or= app.layout.main
  region.show new View(params)
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
      fromIsbn: isbn
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
  data.isbn or= data.normalizedIsbn
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

showViewWithAdminRights = (params)->
  { path, title, View, viewOptions, navigate } = params
  navigate ?= true
  if app.request 'require:loggedIn', path
    if navigate then app.navigate path, { metadata: { title } }
    if app.request 'require:admin:rights'
      app.layout.main.show new View(viewOptions)

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
  edition: 'getEditionView'
  genre: 'getGenreLayout'
  publisher: 'getPublisherLayout'
  article: 'getArticleView'
  # the GenreLayout also fetches movements
  movement: 'getGenreLayout'

isClaim = (claim)-> /^(wdt:|invp:)/.test claim
showClaimEntities = (claim, refresh)->
  [ property, value ] = claim.split '-'

  unless _.isPropertyUri property
    error_.report 'invalid property'
    return app.execute 'show:error:missing'

  unless _.isExtendedEntityUri value
    error_.report 'invalid value'
    return app.execute 'show:error:missing'

  app.layout.main.show new ClaimLayout { property, value, refresh }

reportTypeIssue = (params)->
  { expectedType, model, context } = params
  [ uri, realType ] = model.gets 'uri', 'type'
  if uri in reportedTypeIssueUris then return
  reportedTypeIssueUris.push uri

  subject = "[Entity type] #{uri}: expected #{expectedType}, got #{realType}"
  app.request 'post:feedback', { subject, uris: [ uri ], context }

reportedTypeIssueUris = []

showEntityCleanupFromModel = (entity)->
  if entity.type isnt 'serie'
    err = error_.new "cleanup isn't available for entity type #{type}", 400
    app.execute 'show:error', err
    return

  entity.initSerieParts { refresh: true, fetchAll: true }
  .then ->
    app.layout.main.show new SerieCleanup { model: entity }
    app.navigateFromModel entity, 'cleanup'
