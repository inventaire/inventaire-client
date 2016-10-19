isbn_ = require 'lib/isbn'
wd_ = require 'lib/wikimedia/wikidata'
wdk = require 'lib/wikidata-sdk'
Entity = require './models/entity'
Entities = require './collections/entities'
AuthorLayout = require './views/author_layout'
SerieLayout = require './views/serie_layout'
EntityShow = require './views/entity_show'
EntityEdit = require './views/editor/entity_edit'
GenreLayout= require './views/genre_layout'
error_ = require 'lib/error'
createEntities = require './lib/create_entities'
createEntityDraftModel = require './lib/create_entity_draft_model'
getEntitiesData = require './lib/get_entities_data'
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
    app.entities = new Entities

API =
  showEntity: (uri, label, params, region)->
    region or= app.layout.main
    app.execute 'show:loader', { region }

    [ prefix, id ] = getPrefixId uri
    unless prefix? and id?
      _.warn 'prefix or id missing at showEntity'

    refresh = params?.refresh or app.request('querystring:get', 'refresh')
    if refresh then app.execute 'uriLabel:refresh'

    @_getEntityView prefix, id, refresh
    .then region.show.bind(region)
    # .catch @solveMissingEntity.bind(@, prefix, id)
    .catch handleMissingEntityError.bind(null, 'showEntity err')

  _getEntityView: (prefix, id, refresh)->
    getEntityModel prefix, id, refresh
    .tap replaceEntityPathname.bind(null, '')
    .then @_getDomainEntityView.bind(@, prefix, refresh)

  _getDomainEntityView: (prefix, refresh, entity)->
    switch prefix
      when 'wd', 'inv' then @getWikidataEntityView entity, refresh
      when 'isbn' then @getCommonBookEntityView entity
      else _.error "getDomainEntityView err: unknown domain #{prefix}"

  getWikidataEntityView: (entity, refresh)->
    switch entity.type
      when 'human' then @getAuthorView entity, refresh
      when 'book' then @getCommonBookEntityView entity, refresh
      when 'serie' then @getSerieEntityView entity, refresh
      # display anything else as a genre
      # so that in the worst case it's just a page with a few data
      # and not a page you can 'add to your inventory'
      else new GenreLayout { model: entity }

  getCommonBookEntityView: (model, refresh)-> new EntityShow { model, refresh }
  getSerieEntityView: (model, refresh)->
    new SerieLayout { model, refresh, standalone: true }

  getAuthorView: (entity, refresh)->
    new AuthorLayout
      model: entity
      standalone: true
      displayBooks: true
      initialLength: 20
      refresh: refresh

  showAddEntity: (uri)->
    getEntityModelFromUri uri
    .then (entity)->
      app.execute 'show:item:creation:form',
        entity: entity
        preventDupplicates: true

    # .catch @solveMissingEntity.bind(@, prefix, id)
    .catch handleMissingEntityError.bind(null, 'showAddEntity err')

  showEditEntity: (uri)->
    # make sure we have the freshest data before trying to edit
    getEntityModelFromUri uri, true
    .tap replaceEntityPathname.bind(null, '/edit')
    .then showEntityEdit
    .catch handleMissingEntityError.bind(null, 'showEditEntity err')

  showEntityCreateFromRoute: ->
    type = decodeURIComponent app.request('querystring:get', 'type')
    label = decodeURIComponent app.request('querystring:get', 'label')
    showEntityCreate type, label

  # solveMissingEntity: (prefix, id, err)->
  #   if err.message is 'entity_not_found' then @showCreateEntity id
  #   else throw err

  # showCreateEntity: (isbn)->
  #   app.layout.main.show new EntityCreate
  #     data: isbn
  #     standalone: true

  getEntityPublicItems: (uri)->
    _.preq.get app.API.items.publicByEntity(uri)

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
    'show:entity:edit:from:model': (entity)->
      showEntityEdit entity
      app.navigate entity.get('editable.wiki')

    'show:entity:create': (type, label)->
      showEntityCreate type, label
      path = _.buildPath 'entity/new', { type, label }
      app.navigate path

  app.reqres.setHandlers
    'get:entity:model': getEntityModel
    'get:entity:model:from:uri': getEntityModelFromUri
    'get:entities:models': getEntitiesModelsWithCatcher
    'get:entities:models:from:uris': getEntitiesModelsFromUris
    'get:entity:public:items': API.getEntityPublicItems
    'get:entities:labels': getEntitiesLabels
    'create:entity': createEntity
    'get:entity:local:href': getEntityLocalHref
    'normalize:entity:uri': normalizeEntityUri

getEntitiesModelsFromUris = (uris, refresh)->
  _.type uris, 'array'
  _.types uris, 'strings...'
  # Make sure its a 'true' flag and not an object incidently passed
  refresh = refresh is true

  if uris.length is 0 then return _.preq.resolve []

  getEntitiesData { uris, refresh }
  .then (entities)->
    foundUris = Object.keys entities
    missing = _.difference uris, foundUris
    if missing.length > 0
      _.warn missing, 'missing entities'

    # Return an array of models rather than a collection
    return _.values entities
    .map (entity)->
      # Passing the refresh option to let it be passed to possible subentities
      model = new Entity entity, { refresh }
      app.entities.add model
      return model

getEntitiesModels = (prefix, ids, refresh)->
  uris = ids.map (id)-> "#{prefix}:#{id}"
  getEntitiesModelsFromUris uris, refresh

getEntitiesModelsWithCatcher = ->
  getEntitiesModels.apply null, arguments
  .catch _.Error('getEntitiesModels err')

getEntityModel = (prefix, id, refresh)->
  unless prefix? and id?
    throw error_.new 'missing prefix or id', arguments

  getEntityModelFromUri "#{prefix}:#{id}", refresh

getEntityModelFromUri = (uri, refresh)->
  getEntitiesModelsFromUris [ uri ], refresh
  .then (models)->
    if models?[0]? then return models[0]
    else
      # see getEntitiesModels "Possible reasons for missing entities"
      _.log "getEntityModel entity_not_found: #{prefix}:#{id}"
      throw error_.new 'entity_not_found', [prefix, id, models]

getEntityLabel = (uri)-> app.entities.byUri(uri)?.get 'label'
getEntitiesLabels = (uris)-> uris.map getEntityLabel

getPrefixId = (prefix, id)->
  # resolving the polymorphic interface
  # accepts 'prefix', 'id' or 'prefix:id'
  # returns ['prefix', 'id']

  unless id?
    [ prefix, id ] = prefix?.split ':'
    unless id?
      # trying to guess the prefix when not provided
      if _.isInvEntityId prefix
        [ prefix, id ] = [ 'inv', prefix ]
      else if wdk.isWikidataEntityId prefix
        [ prefix, id ] = [ 'wd', prefix ]

  if prefix? and id? then return [ prefix, id ]
  else throw new Error "prefix and id not found for: #{prefix} / #{id}"

createEntity = (data)->
  createInvEntity data
  .then (entityData)->
    _.type entityData, 'object'
    if entityData.isbn? then model = new IsbnEntity entityData
    else model = new InvEntity entityData
    app.entities.add model
    return model

getEntityLocalHref = (prefix, id, label)->
  # accept both prefix, id or uri-style "#{prefix}:#{id}"
  [ prefix, possibleId ] = prefix?.split(':')
  if possibleId? then [id, label] = [possibleId, id]

  if prefix?.length > 0 and id?.length > 0
    return "/entity/#{prefix}:#{id}"
  else
    throw new Error "couldnt find entityLocalHref: prefix=#{prefix}, id=#{id}, label=#{label}"

normalizeEntityUri = (prefix, id)->
  # accepts either a 'prefix:id' uri or 'prefix', 'id'
  # the polymorphic interface is resolved by getPrefixId
  [ prefix, id ] = getPrefixId(prefix, id)
  if prefix is 'isbn' then id = isbn_.normalizeIsbn id
  return "#{prefix}:#{id}"

showEntityEdit = (entity)->
  view = new EntityEdit { model: entity }
  label = entity?.get 'label'
  if label?
    title = label + ' - ' + _.i18n 'edit'
  else
    title = _.i18n 'new entity'

  app.layout.main.Show view, title

replaceEntityPathname = (suffix, entity)->
  # Correcting possibly custom entity label or missing prefix
  path = entity.get('pathname') + suffix
  app.navigateReplace path

handleMissingEntityError = (label, err)->
  if err.message is 'entity_not_found' then app.execute 'show:error:missing'
  else app.execute 'show:error:other', err, label
