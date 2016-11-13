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
createEntityDraftModel = require './lib/create_entity_draft_model'
entitiesModels = require './lib/get_entities_models'
createInvEntity = require './lib/inv/create_inv_entity'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    EntitiesRouter = Marionette.AppRouter.extend
      appRoutes:
        'entity/new': 'showEntityCreateFromRoute'
        'entity/:uri(/:label)/add(/)': 'showAddEntity'
        'entity/:uri(/:label)/edit(/)': 'showEditEntity'
        'entity/:uri(/:label)(/)': 'showEntity'
        'wd/:qid': 'showWdEntity'
        'isbn/:isbn': 'showIsbnEntity'
        'inv/:id': 'showInvEntity'

    app.addInitializer ->
      new EntitiesRouter
        controller: API

  initialize: ->
    setHandlers()

API =
  showEntity: (uri, label, params, region)->
    uri = normalizeUri uri
    unless _.isEntityUri uri then return app.execute 'show:error:missing'

    region or= app.layout.main
    app.execute 'show:loader', { region }

    refresh = params?.refresh or app.request('querystring:get', 'refresh')
    if refresh then app.execute 'uriLabel:refresh'

    getEntityModel uri, refresh
    .tap replaceEntityPathname.bind(null, '')
    .then @getEntityViewByType.bind(@, refresh)
    .then region.show.bind(region)
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
    .tap replaceEntityPathname.bind(null, '/edit')
    .then showEntityEdit
    .catch handleMissingEntityError.bind(null, 'showEditEntity err')

  showEntityCreateFromRoute: ->
    type = decodeURIComponent app.request('querystring:get', 'type')
    label = decodeURIComponent app.request('querystring:get', 'label')
    showEntityCreate type, label

  # solveMissingEntity: (uri, err)->
  #   if err.message is 'entity_not_found' then @showCreateEntity id
  #   else throw err

  # showCreateEntity: (isbn)->
  #   app.layout.main.show new EntityCreate
  #     data: isbn
  #     standalone: true

  showWdEntity: (qid)-> API.showEntity "wd:#{qid}"
  showIsbnEntity: (isbn)-> API.showEntity "isbn:#{isbn}"
  showInvEntity: (id)-> API.showEntity "inv:#{id}"

showEntityCreate = (type, label)->
  model = createEntityDraftModel
    type: type
    label: label
    # minimized: true
  showEntityEdit model

setHandlers = ->
  app.commands.setHandlers
    'show:entity': (uri, label, params, region)->
      API.showEntity uri, label, params, region
      app.navigate "entity/#{uri}"

    'show:entity:from:model': (model, params, region)->
      uri = model.get('uri')
      if uri? then app.execute 'show:entity', uri, null, params, region
      else throw new Error 'couldnt show:entity:from:model'

    'show:entity:refresh': (model)->
      app.execute 'show:entity:from:model', model, { refresh: true }

    'show:entity:add': API.showAddEntity.bind API
    'show:entity:add:from:model': (model)-> API.showAddEntity model.get('uri')

    'show:entity:edit': API.showEditEntity
    'show:entity:edit:from:model': (entity)->
      showEntityEdit entity
      app.navigate entity.get('edit')

    'show:entity:create': (type, label)->
      showEntityCreate type, label
      path = _.buildPath 'entity/new', { type, label }
      app.navigate path

  app.reqres.setHandlers
    'get:entity:model': getEntityModel
    'get:entities:models': getEntitiesModels
    'get:entity:public:items': getEntityPublicItems
    'create:entity': createEntity
    'get:entity:local:href': getEntityLocalHref

getEntitiesModels = (uris, refresh)->
  _.type uris, 'array'
  _.types uris, 'strings...'
  # Make sure its a 'true' flag and not an object incidently passed
  refresh = refresh is true

  if uris.length is 0 then return _.preq.resolve []

  entitiesModels.get { uris, refresh }
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
  .then entitiesModels.add

getEntityPublicItems = (uri)-> _.preq.get app.API.items.publicByEntity(uri)

getEntityLocalHref = (uri)-> "/entity/#{uri}"

showEntityEdit = (entity)->
  view = new EntityEdit { model: entity }
  label = entity?.get 'label'
  if label?
    title = label + ' - ' + _.i18n 'edit'
  else
    title = _.i18n 'new entity'

  app.layout.main.Show view, title

replaceEntityPathname = (suffix, entity)->
  # Correcting possibly custom entity label
  path = entity.get('pathname') + suffix
  app.navigateReplace path

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
