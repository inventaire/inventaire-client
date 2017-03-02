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
        'entit(y)(ies)(/changes)': 'showChanges'
        'entity/:uri(/:label)/add(/)': 'showAddEntity'
        'entity/:uri(/:label)/edit(/)': 'showEditEntity'
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
    unless _.isEntityUri uri then return app.execute 'show:error:missing'

    app.execute 'show:loader', { region: app.layout.main }

    refresh = params?.refresh or app.request('querystring:get', 'refresh')
    if refresh then app.execute 'uriLabel:refresh'

    getEntityModel uri, refresh
    .tap cleanEntityPathname.bind(null, '')
    .then @getEntityViewByType.bind(@, refresh)
    .then (view)->
      view.model.buildTitleAsync()
      .then (title)-> app.layout.main.Show view, title
    # .catch @solveMissingEntity.bind(@, uri)
    .catch handleMissingEntityError.bind(null, 'showEntity err')

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
        preventDupplicates: true

    # .catch @solveMissingEntity.bind(@, uri)
    .catch handleMissingEntityError.bind(null, 'showAddEntity err')

  showEditEntity: (uri)->
    # make sure we have the freshest data before trying to edit
    getEntityModel uri, true
    .tap cleanEntityPathname.bind(null, '/edit')
    .then showEntityEdit
    .catch handleMissingEntityError.bind(null, 'showEditEntity err')

  showEntityCreateFromRoute: ->
    type = app.request 'querystring:get', 'type'
    label = app.request 'querystring:get', 'label'
    claims = app.request 'querystring:get', 'claims'
    showEntityCreate type, label, claims

  showWdEntity: (qid)-> API.showEntity "wd:#{qid}"
  showIsbnEntity: (isbn)-> API.showEntity "isbn:#{isbn}"
  showInvEntity: (id)-> API.showEntity "inv:#{id}"
  showChanges: ->
    # Only triggered from route yet so any redirection should be a replace
    # to avoid a redirection loop when going back in history
    app.navigateReplace 'entities/changes'
    app.layout.main.Show new ChangesLayout

showEntityCreate = (type, label, claims)->
  unless type in entityDraftModel.whitelistedTypes
    err = error_.new "invalid entity draft type: #{type}", arguments
    return app.execute 'show:error:other', err

  model = entityDraftModel.create { type, label, claims }
  showEntityEdit model

setHandlers = ->
  app.commands.setHandlers
    'show:entity': (uri, label, params)->
      API.showEntity uri, label, params
      app.navigate "entity/#{uri}"

    'show:entity:from:model': (model, params)->
      uri = model.get('uri')
      if uri? then app.execute 'show:entity', uri, null, params
      else throw new Error "couldn't show:entity:from:model"

    'show:entity:refresh': (model)->
      app.execute 'show:entity:from:model', model, { refresh: true }

    'show:entity:add': API.showAddEntity.bind API
    'show:entity:add:from:model': (model)-> API.showAddEntity model.get('uri')

    'show:entity:edit': API.showEditEntity
    'show:entity:edit:from:model': (entity)->
      showEntityEdit entity
      app.navigate entity.get('edit')

    'show:entity:create': (type, label, claims)->
      showEntityCreate type, label, claims
      path = _.buildPath 'entity/new', { type, label, claims }
      app.navigate path

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

showEntityEdit = (entity)->
  editPathname = entity.get 'edit'
  # If this entity edit isn't happening internaly
  # redirect to the page where it should happen,
  # typically on Wikidata.org
  # editPathname might be undefined in the case of a draft entity edit
  if editPathname? and editPathname[0] isnt '/'
    return window.location.href = editPathname

  view = new EntityEdit { model: entity }
  label = entity?.get 'label'
  if label?
    title = label + ' - ' + _.i18n 'edit'
  else
    title = _.i18n 'new entity'

  app.layout.main.Show view, title

cleanEntityPathname = (suffix, entity)->
  # Correcting possibly custom entity label
  path = entity.get('pathname') + suffix
  app.navigate path

handleMissingEntityError = (label, err)->
  if err.message is 'entity_not_found' then app.execute 'show:error:missing'
  else app.execute 'show:error:other', err, label

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
