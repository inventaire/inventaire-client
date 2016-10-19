error_ = require 'lib/error'
{ get:entitiesGet } = app.API.entities

# Draft in-memory cache: might be a dupplicate of app.entities
window.entitiesCache = entitiesCache = {}

module.exports = (params)->
  { uris, prefix, ids, refresh } = params

  if prefix? and ids? then uris = _.forceArray(ids).map (id)-> "#{prefix}:#{id}"

  if refresh then return getRemoteEntities uris, {}, refresh

  foundEntities = getLocalEntities uris
  foundUris = Object.keys foundEntities
  missingUris = _.difference uris, foundUris

  if missingUris.length is 0
    return _.preq.resolve foundEntities

  getRemoteEntities missingUris, foundEntities
  .catch _.ErrorRethrow('get entities data err')

getLocalEntities = (uris)-> _.pick entitiesCache, uris

getRemoteEntities = (uris, foundEntities, refresh)->
  _.preq.get entitiesGet(uris, refresh)
  .then (res)->
    { entities } = res
    # Add the newly fetched entities to the cache
    _.extend entitiesCache, entities
    # Return all the requested entities
    return _.extend foundEntities, entities
