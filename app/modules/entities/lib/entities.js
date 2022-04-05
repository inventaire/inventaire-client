import { isInvEntityId, isWikidataItemId } from '#lib/boolean_tests'
import preq from '#lib/preq'
import { looksLikeAnIsbn, normalizeIsbn } from '#lib/isbn'
import getBestLangValue from './get_best_lang_value.js'
import getOriginalLang from './get_original_lang.js'

export async function getReverseClaims (property, value, refresh, sort) {
  const { uris } = await preq.get(app.API.entities.reverseClaims(property, value, refresh, sort))
  return uris
}

export function normalizeUri (uri) {
  let [ prefix, id ] = uri.split(':')
  if ((id == null)) {
    if (isWikidataItemId(prefix)) {
      [ prefix, id ] = [ 'wd', prefix ]
    } else if (isInvEntityId(prefix)) {
      [ prefix, id ] = [ 'inv', prefix ]
    } else if (looksLikeAnIsbn(prefix)) {
      [ prefix, id ] = [ 'isbn', normalizeIsbn(prefix) ]
    }
  } else {
    if (prefix === 'isbn') id = normalizeIsbn(id)
  }

  if (prefix != null && id != null) {
    return `${prefix}:${id}`
  } else {
    return uri
  }
}

export const getEntitiesByUris = async params => {
  let uris
  let index = false
  if (_.isArray(params)) uris = params
  else ({ uris, index } = params)
  if (uris.length === 0) return []
  let res
  if (uris.length < 100) {
    // Prefer to use get when not fetching that many entities
    // - to make server log the requested URIs
    // - to improve client caching
    res = await preq.get(app.API.entities.getByUris(uris))
  } else {
    // Use the POST endpoint when using a GET might hit some URI length limits
    res = await preq.post(app.API.entities.getManyByUris, { uris })
  }
  const { entities } = res
  const serializedEntities = Object.values(entities).map(serializeEntity)
  if (index) return _.indexBy(serializedEntities, 'uri')
  else return serializedEntities
}

export const getEntityByUri = async ({ uri }) => {
  const [ entity ] = await getEntitiesByUris({ uris: uri })
  return entity
}

export const serializeEntity = entity => {
  entity.originalLang = getOriginalLang(entity.claims)
  entity.label = getBestLangValue(app.user.lang, entity.originalLang, entity.labels).value
  entity.description = getBestLangValue(app.user.lang, entity.originalLang, entity.descriptions).value
  entity.pathname = `/entity/${entity.uri}`
  const [ prefix, id ] = entity.uri.split(':')
  entity.prefix = prefix
  entity.id = id
  return entity
}

export const attachEntities = async (entity, attribute, uris) => {
  entity[attribute] = await getEntitiesByUris(uris)
  return entity
}

export async function getEntitiesAttributesByUris ({ uris, attributes, lang }) {
  return preq.get(app.API.entities.getAttributesByUris({
    uris,
    attributes,
    lang,
  }))
}

export async function getBasicInfoByUri (uri) {
  const { entities, redirects } = await getEntitiesAttributesByUris({
    uris: uri,
    attributes: [ 'type', 'labels', 'descriptions', 'image' ],
    lang: app.user.lang
  })
  const entity = entities[uri]
  if (!entity) {
    return {
      redirection: redirects[uri],
    }
  }
  const label = Object.values(entity.labels)[0]
  let description
  if (entity.descriptions) description = Object.values(entity.descriptions)[0]
  return {
    type: entity.type,
    label,
    description,
    image: entity.image
  }
}

export function getWikidataUrl (uri) {
  const [ prefix, id ] = uri.split(':')
  if (prefix === 'wd') {
    return `https://www.wikidata.org/entity/${id}`
  }
}
