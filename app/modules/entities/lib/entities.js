import { isInvEntityId, isWikidataItemId, isEntityUri, isNonEmptyArray } from '#lib/boolean_tests'
import preq from '#lib/preq'
import { looksLikeAnIsbn, normalizeIsbn } from '#lib/isbn'
import getBestLangValue from './get_best_lang_value.js'
import getOriginalLang from './get_original_lang.js'
import { forceArray } from '#lib/utils'
import { chunk, compact, pluck } from 'underscore'

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
  entity.label = getBestLangValue(app.user.lang, entity.originalLang, entity.labels).value
  if (entity.descriptions) {
    entity.description = getBestLangValue(app.user.lang, entity.originalLang, entity.descriptions).value
  }
  if (entity.claims) {
    entity.publicationYear = getPublicationYear(entity)
    entity.originalLang = getOriginalLang(entity.claims)
    entity.serieOrdinal = getSerieOrdinal(entity.claims)
    const title = entity.claims['wdt:P1476']?.[0]
    if (title) {
      entity.title = title
      entity.subtitle = entity.claims['wdt:P1680']?.[0]
    } else {
      entity.title = entity.label
    }
  }
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

// Limiting the amount of uris requested to not get over the HTTP GET querystring length threshold.
// Not using the POST equivalent endpoint, has duplicated request would then be answered with a 429 error
const getManyEntities = async ({ uris, attributes, lang }) => {
  const urisChunks = chunk(uris, 30)
  const responses = await Promise.all(urisChunks.map(async urisChunks => {
    return preq.get(app.API.entities.getAttributesByUris({ uris: urisChunks, attributes, lang }))
  }))
  return {
    entities: mergeResponsesObjects(responses, 'entities'),
    redirects: mergeResponsesObjects(responses, 'redirects'),
  }
}

const mergeResponsesObjects = (responses, attribute) => {
  const objs = compact(pluck(responses, attribute))
  if (objs.length > 0) {
    return Object.assign(...objs)
  } else {
    return {}
  }
}

export async function getEntitiesAttributesByUris ({ uris, attributes, lang }) {
  uris = forceArray(uris)
  if (!isNonEmptyArray(uris)) return { entities: [] }
  attributes = forceArray(attributes)
  const res = await getManyEntities({ uris, attributes, lang })
  return res
}

export async function getBasicInfoByUri (uri) {
  const { entities, redirects } = await getEntitiesAttributesByUris({
    uris: [ uri ],
    attributes: [ 'type', 'labels', 'descriptions', 'image' ],
    lang: app.user.lang
  })
  const entity = entities[uri]
  if (!entity && redirects) {
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

export async function getEntitiesAttributesFromClaims (claims, attributes) {
  if (!attributes) attributes = [ 'labels' ]
  const claimsValues = _.flatten(Object.values(claims))
  const uris = claimsValues.filter(isEntityUri)
  const { entities } = await getEntitiesAttributesByUris({
    uris,
    attributes,
    lang: app.user.lang
  })
  return entities
}

export function getWikidataUrl (uri) {
  const [ prefix, id ] = uri.split(':')
  if (prefix === 'wd') {
    return `https://www.wikidata.org/entity/${id}`
  }
}

export const getEntityLocalHref = uri => `/entity/${uri}`

const getSerieOrdinal = claims => claims['wdt:P1545']?.[0]

export const bySerieOrdinal = (a, b) => {
  return parseFloat(a.serieOrdinal || 10000) - parseFloat(b.serieOrdinal || 10000)
}

export const byPublicationDate = (a, b) => {
  return parseInt(a.publicationYear || 10000) - parseInt(b.publicationYear || 10000)
}

export const getPublicationYear = entity => {
  const date = entity.claims['wdt:P577']?.[0]
  return getYearFromSimpleDay(date)
}

export const getYearFromSimpleDay = date => {
  if (!date) return
  if (date[0] === '-') {
    const year = date.split('-')[1]
    return `-${year}`
  } else {
    return date.split('-')[0]
  }
}
