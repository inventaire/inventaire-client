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

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'entity/new': 'showEntityCreateFromRoute'
        'entity/changes': 'showChanges'
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
    uri = normalizeUri uri
    unless _.isExtendedEntityUri uri then return app.execute 'show:error:missing'

    app.execute 'show:loader', { region: app.layout.main }

    refresh = params?.refresh or app.request('querystring:get', 'refresh')
    if refresh then app.execute 'uriLabel:refresh'

    getEntityModel uri, refresh
    .tap app.navigateFromModel
    .then @getEntityViewByType.bind(@, refresh)
    .then app.layout.main.show.bind(app.layout.main)
    .catch handleMissingEntity(uri)

  getEntityViewByType: (refresh, entity)->
    switch entity.type
      when 'human' then @getAuthorView entity, refresh
      when 'serie' then @getSerieView entity, refresh
      when 'work' then @getWorkView entity, refresh
      when 'edition' then @getWorkViewFromEdition entity, refresh
      # display anything else as a genre
      # so that in the worst case it's just a page with a few data
      # and not a page you can 'add to your inventory'
      else new GenreLayout { model: entity }

  getAuthorView: (entity, refresh)->
    new AuthorLayout
      model: entity
      standalone: true
      initialLength: 20
      refresh: refresh

  getSerieView: (model, refresh)->
    new SerieLayout { model, refresh, standalone: true }

  getWorkView: (model, refresh)-> new WorkLayout { model, refresh }

  getWorkViewFromEdition: (model, refresh)-> new EditionLayout { model, refresh, standalone: true }

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
    showEntityCreate app.request('querystring:get:full')

  showWdEntity: (qid)-> API.showEntity "wd:#{qid}"
  showIsbnEntity: (isbn)-> API.showEntity "isbn:#{isbn}"
  showInvEntity: (id)-> API.showEntity "inv:#{id}"
  showChanges: ->
    app.layout.main.show new ChangesLayout
    app.navigate 'entity/changes', { metadata: { title: 'changes' } }

showEntityCreate = (params)->
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

  app.reqres.setHandlers
    'get:entity:model': getEntityModel
    'get:entities:models': getEntitiesModels
    'create:entity': createEntity
    'get:entity:local:href': getEntityLocalHref
    'entity:exists:or:create:from:seed': existsOrCreateFromSeed

getEntitiesModels = (uris, refresh, defaultType)->
  _.type uris, 'array'
  _.types uris, 'strings...'
  # Make sure its a 'true' flag and not an object incidently passed
  refresh = refresh is true

  if uris.length is 0 then return _.preq.resolve []

  entitiesModelsIndex.get { uris, refresh, defaultType }
  .then _.values

getEntityModel = (uri, refresh)->
  getEntitiesModels [ uri ], refresh
  .then (models)->
    if models?[0]? then return models[0]
    else
      # see getEntitiesModels "Possible reasons for missing entities"
      _.log "getEntityModel entity_not_found: #{uri}"
      throw error_.new 'entity_not_found', [uri, models]

createEntity = (data)->
  createInvEntity data
  .then entitiesModelsIndex.add

getEntityLocalHref = (uri)-> "/entity/#{uri}"

showEntityEdit = (params)->
  { model } = params
  editPathname = model.get 'edit'
  # If this entity edit isn't happening internaly
  # redirect to the page where it should happen,
  # typically on Wikidata.org
  # editPathname might be undefined in the case of a draft entity edit
  if editPathname? and editPathname[0] isnt '/'
    return window.location.href = editPathname

  app.layout.main.show new EntityEdit(params)
  app.navigateFromModel model, 'edit'

showEntityEditFromModel = (model)-> showEntityEdit { model }

handleMissingEntity = (uri)-> (err)->
  unless err.message is 'entity_not_found'
    return app.execute 'show:error:other', err, 'handleMissingEntity'

  [ prefix, id ] = uri.split ':'
  if prefix is 'isbn' then showEntityCreateFromIsbn id
  else app.execute 'show:error:missing'

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
    if isbn_.isNormalizedIsbn prefix then [ prefix, id ] = [ 'isbn', prefix ]
    else if wdk.isWikidataEntityId prefix then [ prefix, id ] = [ 'wd', prefix ]
    else if _.isInvEntityId prefix then [ prefix, id ] = [ 'inv', prefix ]
  else
    if prefix is 'isbn' then id = isbn_.normalizeIsbn id

  return "#{prefix}:#{id}"

# Create from the seed data we have, if the entity isn't known yet
existsOrCreateFromSeed = (data)->
  _.preq.post app.API.entities.existsOrCreateFromSeed, data
  # Add the possibly newly created edition entity to the local index
  # and get it's model
  .then entitiesModelsIndex.add
