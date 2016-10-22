error_ = require 'lib/error'
Entity = require '../models/entity'
{ get:entitiesGet } = app.API.entities

# In-memory cache for all entities used during a session
entitiesModelsIndexedByUri = {}

exports.get = (params)->
  { uris, prefix, ids, refresh } = params

  if prefix? and ids? then uris = _.forceArray(ids).map (id)-> "#{prefix}:#{id}"

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
