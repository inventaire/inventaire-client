error_ = require 'lib/error'
Entity = require '../models/entity'
{ get:entitiesGet } = app.API.entities

# In-memory cache for all entities used during a session
# It's ok to attach it to window for inspection purpose
# as we aren't letting it a change to be garbage collected anyway
window.entitiesModelsIndexedByUri = entitiesModelsIndexedByUri = {}

exports.get = (params)->
  { uris, refresh } = params
  uris = _.uniq uris
  if refresh then return getRemoteEntitiesModels uris, {}, refresh

  foundEntitiesModels = getLocalEntities uris
  foundUris = Object.keys foundEntitiesModels
  missingUris = _.difference uris, foundUris

  if missingUris.length is 0
    return _.preq.resolve foundEntitiesModels

  getRemoteEntitiesModels missingUris, foundEntitiesModels
  .catch _.ErrorRethrow('get entities data err')

getLocalEntities = (uris)-> _.pick entitiesModelsIndexedByUri, uris

getRemoteEntitiesModels = (uris, foundEntitiesModels, refresh)->
  _.preq.get entitiesGet(uris, refresh)
  .then (res)->
    { entities:entitiesData, redirects } = res

    newEntities = {}
    for uri, entityData of entitiesData
      newEntities[uri] = new Entity entityData

    aliasRedirects newEntities, redirects
    logMissingEntities newEntities, uris

    # Add the newly fetched entities to the cache
    _.extend entitiesModelsIndexedByUri, newEntities

    # Return all the requested entities
    return _.extend foundEntitiesModels, newEntities

# Add links to the redirected entities objects
aliasRedirects = (entities, redirects)->
  for from, to of redirects
    entities[from] = entities[to]

  return

logMissingEntities = (newEntities, requestedUris)->
  newEntitiesUris = Object.keys newEntities
  missingUris = _.difference requestedUris, newEntitiesUris
  if missingUris.length > 0
    _.error missingUris, 'entities not found'

exports.add = (entityData)->
  { uri } = entityData
  unless _.isEntityUri uri then throw error_.new "invalid uri: #{uri}", entityData
  return entitiesModelsIndexedByUri[uri] = new Entity entityData
