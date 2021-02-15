import { props as promiseProps } from 'lib/promises'
import { isModel, isEntityUri } from 'lib/boolean_tests'
import { forceArray } from 'lib/utils'
import log_ from 'lib/loggers'
import preq from 'lib/preq'
import error_ from 'lib/error'
import Entity from '../models/entity'
import { invalidateLabel } from 'lib/uri_label/labels_helpers'

// In-memory cache for all entities used during a session.
// It's ok to attach it to window for inspection purpose
// as we aren't letting it a chance to be garbage collected anyway
// Each value can be either an entity model or a promise of an entity model.
// Once resolved, the promise object will be replaced by the entity model.
// The main vertue of this is to allow to request an entity only once and then mutualize
// the generated promise between several consumers.
// The only known duplicate request remaining is when an entity is requested from
// an alias uri and then re-requested from its canonical uri before the first entity
// returned.
const entitiesModelsIndexedByUri = {}

export function get (params) {
  let missingUris
  let { uris, refresh, defaultType } = params
  uris = _.uniq(uris)

  if (refresh) {
    missingUris = uris
  } else {
    missingUris = getMissingUris(uris)
  }

  if (missingUris.length > 0) {
    // Populate entitiesModelsIndexedByUri with promises of entity models
    // for the missing entities
    populateIndexWithMissingEntitiesModelsPromises(missingUris, refresh, defaultType)
  }

  // Return a promise that should resolved to an object
  // with all the requested entities models
  return pickEntitiesModelsPromises(uris)
}

const getMissingUris = function (uris) {
  const foundUris = Object.keys(entitiesModelsIndexedByUri)
  return _.difference(uris, foundUris)
}

// This is where the magic happens: we are picking values from an object made of
// entity models and promises of entity models, but promiseProps transforms it into
// a unique promise of an index of entity models
const pickEntitiesModelsPromises = uris => promiseProps(_.pick(entitiesModelsIndexedByUri, uris))

const populateIndexWithMissingEntitiesModelsPromises = function (uris, refresh, defaultType) {
  const getEntitiesPromise = getRemoteEntitiesModels(uris, refresh, defaultType)
  for (const uri of uris) {
    // Populate the index with individual promises
    entitiesModelsIndexedByUri[uri] = inidivualPromise(getEntitiesPromise, uri)
  }
  // But return nothing: let pickEntitiesModelsPromises take what it needs from those
}

const getRemoteEntitiesModels = function (uris, refresh, defaultType) {
  let promise
  if (uris.length < 50) {
    // Prefer to use get when not fetching that many entities
    // - to make server log the requested URIs
    promise = preq.get(app.API.entities.getByUris(uris, refresh))
  } else {
    // Use the POST endpoint when using a GET might hit some URI length limits
    promise = preq.post(app.API.entities.getManyByUris, { uris, refresh })
  }

  return promise
  .then(res => {
    const { entities: entitiesData, redirects } = res

    const newEntities = {}
    for (const uri in entitiesData) {
      const entityData = entitiesData[uri]
      const currentIndexValue = entitiesModelsIndexedByUri[uri]
      // In the case an entity was requested from two different uris (e.g. the canonical
      // and an alias), checking the current index value allows to prevent initializing
      // twice a same model
      if (isModel(currentIndexValue)) {
        newEntities[uri] = currentIndexValue
      } else {
        newEntities[uri] = new Entity(entityData, { defaultType, refresh })
      }
    }

    aliasRedirects(newEntities, redirects)

    // Replace the entities models promises by their models:
    // saves the extra space taken by the promise object
    _.extend(entitiesModelsIndexedByUri, newEntities)

    return newEntities
  })
  .catch(log_.ErrorRethrow('get entities data err'))
}

const inidivualPromise = (collectivePromise, uri) => collectivePromise.then(_.property(uri))

// Add links to the redirected entities objects
const aliasRedirects = function (entities, redirects) {
  for (const from in redirects) {
    const to = redirects[from]
    entities[from] = entities[to]
  }
}

// Used when an entity is created locally and needs to be added to the index
export const addModel = function (entityModel) {
  const uri = entityModel.get('uri')
  entitiesModelsIndexedByUri[uri] = entityModel
  return entityModel
}

export function add (entityData) {
  const { uri } = entityData
  if (!isEntityUri(uri)) throw error_.new(`invalid uri: ${uri}`, entityData)
  return addModel(new Entity(entityData))
}

const sanitizeUris = uris => _.uniq(_.compact(forceArray(uris)))

const invalidateCache = function (uri) {
  delete entitiesModelsIndexedByUri[uri]
  invalidateLabel(uri)
}

// Softer than invalidateCache: simply setting a flag to be taken into account
// by Entity::fetchSubEntities on next call
const invalidateGraph = function (uri) {
  if (entitiesModelsIndexedByUri[uri] != null) {
    entitiesModelsIndexedByUri[uri].graphChanged = true
  } else {
    log_.warn(uri, "entity not found in cache: can't invalidate cache")
  }
}

// Work around circular dependency
setTimeout(() => {
  app.commands.setHandlers({
    'invalidate:entities:graph': uris => sanitizeUris(uris).forEach(invalidateGraph),
    'invalidate:entities:cache': uris => sanitizeUris(uris).forEach(invalidateCache)
  })
}, 0)
