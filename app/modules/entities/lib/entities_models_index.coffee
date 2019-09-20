error_ = require 'lib/error'
Entity = require '../models/entity'
{ getByUris, getManyByUris } = app.API.entities
{ invalidateLabel } = require 'lib/uri_label/labels_helpers'

# In-memory cache for all entities used during a session.
# It's ok to attach it to window for inspection purpose
# as we aren't letting it a chance to be garbage collected anyway
# Each value can be either an entity model or a promise of an entity model.
# Once resolved, the promise object will be replaced by the entity model.
# The main vertue of this is to allow to request an entity only once and then mutualize
# the generated promise between several consumers.
# The only known duplicate request remaining is when an entity is requested from
# an alias uri and then re-requested from its canonical uri before the first entity
# returned.
entitiesModelsIndexedByUri = {}

exports.get = (params)->
  { uris, refresh, defaultType } = params
  uris = _.uniq uris

  if refresh then missingUris = uris
  else missingUris = getMissingUris uris

  if missingUris.length > 0
    # Populate entitiesModelsIndexedByUri with promises of entity models
    # for the missing entities
    populateIndexWithMissingEntitiesModelsPromises missingUris, refresh, defaultType

  # Return a promise that should resolved to an object
  # with all the requested entities models
  return pickEntitiesModelsPromises uris

getMissingUris = (uris)->
  foundUris = Object.keys entitiesModelsIndexedByUri
  return _.difference uris, foundUris

# This is where the magic happens: we are picking values from an object made of
# entity models and promises of entity models, but Promise.props transforms it into
# a unique promise of an index of entity models
pickEntitiesModelsPromises = (uris)->
  Promise.props _.pick(entitiesModelsIndexedByUri, uris)

populateIndexWithMissingEntitiesModelsPromises = (uris, refresh, defaultType)->
  getEntitiesPromise = getRemoteEntitiesModels uris, refresh, defaultType
  for uri in uris
    # Populate the index with individual promises
    entitiesModelsIndexedByUri[uri] = inidivualPromise getEntitiesPromise, uri
  # But return nothing: let pickEntitiesModelsPromises take what it needs from those
  return

getRemoteEntitiesModels = (uris, refresh, defaultType)->
  if uris.length < 50
    # Prefer to use get when not fetching that many entities
    # - to make server log the requested URIs
    promise = _.preq.get getByUris(uris, refresh)
  else
    # Use the POST endpoint when using a GET might hit some URI length limits
    promise = _.preq.post getManyByUris(refresh), { uris }

  promise
  .then (res)->
    { entities:entitiesData, redirects } = res

    newEntities = {}
    for uri, entityData of entitiesData
      currentIndexValue = entitiesModelsIndexedByUri[uri]
      # In the case an entity was requested from two different uris (e.g. the canonical
      # and an alias), checking the current index value allows to prevent initializing
      # twice a same model
      if _.isModel currentIndexValue
        newEntities[uri] = currentIndexValue
      else
        newEntities[uri] = new Entity entityData, { defaultType, refresh }

    aliasRedirects newEntities, redirects

    # Replace the entities models promises by their models:
    # saves the extra space taken by the promise object
    _.extend entitiesModelsIndexedByUri, newEntities

    return newEntities
  .catch _.ErrorRethrow('get entities data err')

inidivualPromise = (collectivePromise, uri)->  collectivePromise.then _.property(uri)

# Add links to the redirected entities objects
aliasRedirects = (entities, redirects)->
  for from, to of redirects
    entities[from] = entities[to]
  return

# Used when an entity is created locally and needs to be added to the index
exports.addModel = addModel = (entityModel)->
  uri = entityModel.get 'uri'
  return entitiesModelsIndexedByUri[uri] = entityModel

exports.add = (entityData)->
  { uri } = entityData
  unless _.isEntityUri uri then throw error_.new "invalid uri: #{uri}", entityData
  return addModel new Entity(entityData)

sanitizeUris = (uris)-> _.uniq _.compact(_.forceArray(uris))

invalidateCache = (uri)->
  delete entitiesModelsIndexedByUri[uri]
  invalidateLabel uri

# Softer than invalidateCache: simply setting a flag to be taken into account
# by Entity::fetchSubEntities on next call
invalidateGraph = (uri)-> entitiesModelsIndexedByUri[uri].graphChanged = true

app.commands.setHandlers
  'invalidate:entities:graph': (uris)-> sanitizeUris(uris).forEach invalidateGraph
  'invalidate:entities:cache': (uris)-> sanitizeUris(uris).forEach invalidateCache
