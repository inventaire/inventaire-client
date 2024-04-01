import { flatten, chunk, compact, indexBy, pluck } from 'underscore'
import app from '#app/app'
import { getOwnersCountPerEdition } from '#entities/components/lib/edition_action_helpers'
import assert_ from '#lib/assert_types'
import { isInvEntityId, isWikidataItemId, isEntityUri, isNonEmptyArray, isImageHash } from '#lib/boolean_tests'
import { looksLikeAnIsbn, normalizeIsbn } from '#lib/isbn'
import preq from '#lib/preq'
import { expired } from '#lib/time'
import { forceArray } from '#lib/utils'
import type { Claims, InvClaimValue, EntityUri } from '#server/types/entity'
import type { SerializedEntityWithLabel, RedirectionsByUris } from '#types/entity'
import getBestLangValue from './get_best_lang_value.ts'
import getOriginalLang from './get_original_lang.ts'
import type { Entries } from 'type-fest'

type EntitiesByUris = Record<EntityUri, SerializedEntityWithLabel>

interface GetEntitiesParams {
  uris: InvClaimValue[]
  attributes?: unknown
  lang?: unknown
  relatives?: unknown
}

export async function getReverseClaims (property, value, refresh?, sort?) {
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

export const getEntities = async uris => {
  if (uris.length === 0) return []
  const { entities } = await getManyEntities({ uris })
  return Object.values(entities).map(serializeEntity) as SerializedEntityWithLabel[]
}

export const getEntitiesByUris = async (params: GetEntitiesParams) => {
  const { uris, attributes, lang } = params
  if (uris.length === 0) return []
  const { entities, redirects } = await getManyEntities({ uris, attributes, lang })
  const serializedEntities = Object.values(entities).map(serializeEntity) as SerializedEntityWithLabel[]
  const serializedEntitiesByUris = indexBy(serializedEntities, 'uri')
  addRedirectionsAliases(serializedEntitiesByUris, redirects)
  return serializedEntitiesByUris
}

export const getEntityByUri = async ({ uri }) => {
  assert_.string(uri)
  const entities = await getEntities([ uri ])
  return entities[0]
}

export const serializeEntity = entity => {
  const { value: label, lang: labelLang } = getBestLangValue(app.user.lang, entity.originalLang, entity.labels)
  entity.label = label
  entity.labelLang = labelLang
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
  const basePathname = entity.pathname = getPathname(entity.uri)
  entity.editPathname = `${basePathname}/edit`
  entity.historyPathname = `${basePathname}/history`
  const [ prefix, id ] = entity.uri.split(':')
  entity.prefix = prefix
  entity.id = id
  entity.isWikidataEntity = prefix === 'wd'
  return entity
}

const getPathname = uri => `/entity/${uri}`

export const attachEntities = async (entity, attribute, uris) => {
  entity[attribute] = await getEntities(uris)
  return entity
}

// Limiting the amount of uris requested to not get over the HTTP GET querystring length threshold.
// Not using the POST equivalent endpoint, has duplicated request would then be answered with a 429 error
// Also, do not export function to consumers clean, one may import getEntities or getEntitiesByUris
const getManyEntities = async ({ uris, attributes, lang, relatives }: GetEntitiesParams) => {
  const urisChunks = chunk(uris, 30)
  const responses = await Promise.all(urisChunks.map(async urisChunks => {
    return preq.get(app.API.entities.getAttributesByUris({ uris: urisChunks, attributes, lang, relatives }))
  }))
  return {
    entities: mergeResponsesObjects(responses, 'entities'),
    redirects: mergeResponsesObjects(responses, 'redirects'),
  } as { entities: EntitiesByUris, redirects: RedirectionsByUris }
}

const mergeResponsesObjects = (responses, attribute) => {
  const objs = compact(pluck(responses, attribute))
  if (objs.length > 0) {
    // @ts-expect-error
    return Object.assign(...objs)
  } else {
    return {}
  }
}

interface GetEntitiesAttributesByUris {
  uris: InvClaimValue[]
  attributes: string[]
  lang?: string
  relatives?: any
}

export async function getEntitiesAttributesByUris ({ uris, attributes, lang, relatives }: GetEntitiesAttributesByUris) {
  uris = forceArray(uris)
  let entities: EntitiesByUris = {}
  if (!isNonEmptyArray(uris)) {
    return { entities }
  }
  let redirects: RedirectionsByUris = {}
  attributes = forceArray(attributes)
  ;({ entities, redirects } = await getManyEntities({ uris, attributes, lang, relatives }))
  addRedirectionsAliases(entities, redirects)
  return { entities }
}

function addRedirectionsAliases (entities, redirects) {
  if (redirects) {
    for (const [ fromUri, toUri ] of Object.entries(redirects) as Entries<RedirectionsByUris>) {
      entities[fromUri] = entities[toUri]
    }
  }
}

export async function getEntitiesBasicInfoByUris (uris) {
  return getEntitiesByUris({
    uris,
    attributes: [ 'info', 'labels', 'descriptions', 'image' ],
    lang: app.user.lang,
  })
}

export async function getAndAssignPopularity ({ entities }) {
  const uris = []
  let wdUrisCount = 0
  entities.forEach(entity => {
    const { uri } = entity
    if (entity.popularity === undefined) {
      uris.push(uri)
      if (uri.startsWith('wd:')) wdUrisCount++
    }
  })
  if (!isNonEmptyArray(uris)) return entities
  // Limiting refresh to not overcrowd Wikidata
  const refresh = wdUrisCount < 30
  const urisChunks = chunk(uris, 30)
  const responses = await Promise.all(urisChunks.map(async urisChunk => {
    return preq.get(app.API.entities.popularity(urisChunk, refresh))
  }))
  const scores = mergeResponsesObjects(responses, 'scores')

  entities.forEach(entity => {
    const popularity = scores[entity.uri]
    if (popularity >= 0) entity.popularity = popularity
  })
}

export async function getEntityBasicInfoByUri (uri) {
  const entities = await getEntitiesBasicInfoByUris([ uri ])
  return entities[uri]
}

export async function getEntitiesAttributesFromClaims (claims: Claims, attributes) {
  if (!attributes) attributes = [ 'labels' ]
  const claimsValues = flatten(Object.values(claims))
  const uris = claimsValues.filter(isEntityUri)
  const { entities } = await getEntitiesAttributesByUris({
    uris,
    attributes,
    lang: app.user.lang,
  })
  return entities
}

export function getWikidataUrl (uri) {
  const [ prefix, id ] = uri.split(':')
  if (prefix === 'wd') {
    return `https://www.wikidata.org/entity/${id}`
  }
}

export function getWikidataHistoryUrl (uri) {
  const [ prefix, id ] = uri.split(':')
  if (prefix === 'wd') {
    return `https://www.wikidata.org/w/index.php?title=${id}&action=history`
  }
}

export const getEntityLocalHref = uri => `/entity/${uri}`

const getSerieOrdinal = claims => claims['wdt:P1545']?.[0]

export const bySerieOrdinal = (a, b) => {
  return parseFloat(a.serieOrdinal || 10000) - parseFloat(b.serieOrdinal || 10000)
}

export const byPublicationDate = (a, b) => {
  // Ascendant order
  return parseInt(a.publicationYear || 10000) - parseInt(b.publicationYear || 10000)
}

export const byNewestPublicationDate = (a, b) => {
  // Descending order
  return parseInt(b.publicationYear || 0) - parseInt(a.publicationYear || 0)
}

export function byPopularity (a, b) {
  // Descending order
  return parseInt(b.popularity || 0) - parseInt(a.popularity || 0)
}

export function byItemsOwnersCount (a, b) {
  // Descending order
  return (getOwnersCountPerEdition(b.items) || 0) - (getOwnersCountPerEdition(a.items) || 0)
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

export async function getEntitiesImages (uris) {
  if (uris.length === 0) return {}
  const { images } = await preq.get(app.API.entities.images(uris))
  return images
}

export async function getEntityImage (uri) {
  const images = getEntitiesImages(uri)
  return images[uri]
}
export async function getEntitiesImagesUrls (uris) {
  const images = await getEntitiesImages(uris)
  return extractImagesUrls(images)
}

export async function getEntityImageUrl (uri) {
  const imagesUrls = await getEntitiesImagesUrls([ uri ])
  return imagesUrls[0]
}

export function extractImagesUrls (images) {
  const imageUrls = Object.values(images).map(entityImages => {
    const firstImage = getBestLangValue(app.user.lang, null, entityImages).value
    if (firstImage) return getEntityImagePath(firstImage)
  })
  return compact(imageUrls)
}

export const getEntityImagePath = imageValue => {
  if (isImageHash(imageValue)) return `/img/entities/${imageValue}`
  else return imageValue
}

export function entityDataShouldBeRefreshed (entity) {
  return entity.refreshTimestamp && !expired(entity.refreshTimestamp, 1000)
}

export function pushEntityRefreshingPromise (entity, promise) {
  entity.refreshing = Promise.all([ entity.refreshing, promise ])
}
