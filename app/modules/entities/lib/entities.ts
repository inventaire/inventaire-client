import { flatten, chunk, compact, indexBy, pluck, values, without } from 'underscore'
import { API } from '#app/api/api'
import { assertString } from '#app/lib/assert_types'
import { isInvEntityId, isWikidataItemId, isEntityUri, isNonEmptyArray, isImageHash } from '#app/lib/boolean_tests'
import { newError } from '#app/lib/error'
import { looksLikeAnIsbn, normalizeIsbn } from '#app/lib/isbn'
import type { MetadataUpdate } from '#app/lib/metadata/update'
import preq from '#app/lib/preq'
import { forceArray, objectEntries } from '#app/lib/utils'
import type { Entity, InvEntity, RedirectionsByUris, RemovedPlaceholder, WdEntity } from '#app/types/entity'
import { getOwnersCountPerEdition } from '#entities/components/lib/edition_action_helpers'
import type { GetEntitiesParams } from '#server/controllers/entities/by_uris_get'
import type { RelativeUrl, Url } from '#server/types/common'
import type { Claims, EntityUri, EntityUriPrefix, EntityId, PropertyUri, InvClaimValue, WdEntityId, WdEntityUri, InvEntityId, NormalizedIsbn, InvEntityUri, ClaimValueByProperty } from '#server/types/entity'
import { mainUser } from '#user/lib/main_user'
import { getBestLangValue } from './get_best_lang_value.ts'
import getOriginalLang from './get_original_lang.ts'
import type { WikimediaLanguageCode } from 'wikibase-sdk'

export interface SerializedEntityCommons {
  label?: string
  labelLang?: WikimediaLanguageCode
  description?: string
  publicationYear?: string
  serieOrdinal?: string
  serieOrdinalNum?: number
  title?: string
  subtitle?: string
  pathname?: RelativeUrl
  editPathname?: RelativeUrl
  historyPathname?: RelativeUrl
  cleanupPathname?: RelativeUrl
  prefix: EntityUriPrefix
  // Can be set by #app/lib/types/work_alt.ts#setEntityImages
  images?: Url[]
  // Can be set by #entities/lib/document_metadata.ts
  _gettingMetadata?: Promise<MetadataUpdate>
}

export type SerializedInvEntity = InvEntity & SerializedEntityCommons & {
  id: InvEntityId | NormalizedIsbn
  isWikidataEntity: false
  wdId: never
  wdUri: never
  invUri: InvEntityUri
}
export type SerializedRemovedPlaceholder = RemovedPlaceholder & SerializedEntityCommons & {
  id: InvEntityId
  invUri: InvEntityUri
  wdId: never
  wdUri: never
  isWikidataEntity: false
}
export type SerializedWdEntity = WdEntity & SerializedEntityCommons & {
  wdId: WdEntityId
  wdUri: WdEntityUri
  invUri?: InvEntityUri
  isWikidataEntity: true
}

export type SerializedEntity = SerializedInvEntity | SerializedRemovedPlaceholder | SerializedWdEntity

export type SerializedEntitiesByUris = Record<EntityUri, SerializedEntity>

type GetEntitiesAttributesByUrisParams = Pick<GetEntitiesParams, 'uris' | 'attributes' | 'lang' | 'relatives' | 'refresh' | 'autocreate'>

export async function getReverseClaims (property: PropertyUri, value: InvClaimValue, refresh?: boolean, sort?: boolean) {
  const { uris } = await preq.get(API.entities.reverseClaims(property, value, refresh, sort))
  return uris as EntityUri[]
}

export function normalizeUri (uri: string) {
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
    return `${prefix}:${id}` as EntityUri
  } else {
    return uri as EntityUri
  }
}

export async function getEntities (uris: EntityUri[], params: Omit<GetEntitiesAttributesByUrisParams, 'uris'> = {}) {
  if (uris.length === 0) return []
  const { entities } = await getManyEntities({ uris, ...params })
  return values(entities).map(serializeEntity)
}

export async function getEntitiesByUris (params: GetEntitiesParams) {
  const { uris, attributes, lang } = params
  if (uris.length === 0) return {}
  const { entities, redirects } = await getManyEntities({ uris, attributes, lang })
  const serializedEntities = values(entities).map(serializeEntity)
  const serializedEntitiesByUris = indexBy(serializedEntities, 'uri')
  addRedirectionsAliases(serializedEntitiesByUris, redirects)
  return serializedEntitiesByUris as SerializedEntitiesByUris
}

export async function getEntityByUri ({ uri, refresh, autocreate }: { uri: InvEntityUri, refresh?: boolean, autocreate?: boolean }): Promise<SerializedInvEntity>
export async function getEntityByUri ({ uri, refresh, autocreate }: { uri: WdEntityUri, refresh?: boolean, autocreate?: boolean }): Promise<SerializedWdEntity>
export async function getEntityByUri ({ uri, refresh, autocreate }: { uri: EntityUri, refresh?: boolean, autocreate?: boolean }): Promise<SerializedEntity>
export async function getEntityByUri ({ uri, refresh = false, autocreate }: { uri: EntityUri, refresh?: boolean, autocreate?: boolean }): Promise<SerializedEntity> {
  assertString(uri)
  const entities = await getEntities([ uri ], { refresh, autocreate })
  const entity = entities[0]
  if (entity) {
    return entity
  } else {
    const err = newError('entity_not_found', 404, { uri })
    err.code = 'entity_not_found'
    throw err
  }
}

export function serializeEntity (entity: Entity & Partial<SerializedEntity>) {
  const { value: label, lang: labelLang } = getBestLangValue(mainUser.lang, entity.originalLang, entity.labels)
  entity.label = label
  entity.labelLang = labelLang
  if ('descriptions' in entity) {
    entity.description = getBestLangValue(mainUser.lang, entity.originalLang, entity.descriptions).value
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
  const basePathname = entity.pathname = getEntityPathname(entity.uri)
  entity.editPathname = `${basePathname}/edit`
  entity.historyPathname = `${basePathname}/history`
  entity.cleanupPathname = `${basePathname}/cleanup`

  let wdUri, invUri
  let isWikidataEntity = false
  const { invId, wdId } = entity
  if (wdId) {
    isWikidataEntity = true
    wdUri = `wd:${wdId}`
  }
  if (invId) {
    invUri = `inv:${invId}`
  }
  const [ prefix, id ] = entity.uri.split(':')
  Object.assign(entity, {
    id: id as EntityId,
    prefix: prefix as EntityUriPrefix,
    wdUri,
    invUri,
    isWikidataEntity,
  })
  // Legacy
  entity.image ??= {}
  // Returning the same object so that if attributes are added later to the entity object,
  // (typically .images) they are also available on the serialized entity object
  return entity as SerializedEntity
}

export const getEntityPathname = (uri: EntityUri) => `/entity/${uri}` as RelativeUrl

export async function attachEntities (entity: Entity | SerializedEntity, attribute: string, uris: EntityUri[]) {
  entity[attribute] = await getEntities(uris)
  return entity
}

// Limiting the amount of uris requested to not get over the HTTP GET querystring length threshold.
// Not using the POST equivalent endpoint, has duplicated request would then be answered with a 429 error
// Also, do not export function to consumers clean, one may import getEntities or getEntitiesByUris
async function getManyEntities ({ uris, attributes, lang, relatives, refresh, autocreate }: GetEntitiesAttributesByUrisParams) {
  const urisChunks = chunk(uris, 30)
  const responses = await Promise.all(urisChunks.map(async urisChunks => {
    return preq.get(API.entities.getAttributesByUris({ uris: urisChunks, attributes, lang, relatives, refresh, autocreate }))
  }))
  const entities: SerializedEntitiesByUris = mergeResponsesObjects(responses, 'entities')
  const redirects: RedirectionsByUris = mergeResponsesObjects(responses, 'redirects')
  return { entities, redirects }
}

function mergeResponsesObjects (responses, attribute) {
  const objs = compact(pluck(responses, attribute))
  if (objs.length > 0) {
    // @ts-expect-error
    return Object.assign(...objs)
  } else {
    return {}
  }
}

export async function getEntitiesAttributesByUris ({ uris, attributes, lang, relatives, refresh, autocreate }: GetEntitiesAttributesByUrisParams) {
  uris = forceArray(uris)
  let entities: SerializedEntitiesByUris = {}
  if (!isNonEmptyArray(uris)) {
    return { entities }
  }
  let redirects: RedirectionsByUris = {}
  ;({ entities, redirects } = await getManyEntities({ uris, attributes, lang, relatives, refresh, autocreate }))
  values(entities).forEach(serializeEntity)
  addRedirectionsAliases(entities, redirects)
  return { entities }
}

export async function getEntitiesList ({ uris, attributes, lang, relatives, refresh, autocreate }: GetEntitiesAttributesByUrisParams) {
  const { entities } = await getEntitiesAttributesByUris({ uris, attributes, lang, relatives, refresh, autocreate })
  return values(entities)
}

function addRedirectionsAliases (entities: SerializedEntitiesByUris, redirects: RedirectionsByUris) {
  if (redirects) {
    for (const [ fromUri, toUri ] of objectEntries(redirects)) {
      entities[fromUri] = entities[toUri]
    }
  }
}

export async function getEntitiesBasicInfoByUris (uris: EntityUri[]) {
  return getEntitiesByUris({
    uris,
    attributes: [ 'info', 'labels', 'descriptions', 'image' ],
    lang: mainUser.lang,
  })
}

export async function getEntityLabel (uri: EntityUri) {
  const entities = await getEntitiesByUris({
    uris: [ uri ],
    attributes: [ 'labels' ],
    lang: mainUser.lang,
  })
  const entity = values(entities)[0]
  const { value, lang } = getBestLangValue(mainUser.lang, null, entity.labels)
  return { label: value, lang }
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
    return preq.get(API.entities.popularity(urisChunk, refresh))
  }))
  const scores = mergeResponsesObjects(responses, 'scores')

  entities.forEach(entity => {
    const popularity = scores[entity.uri]
    if (popularity >= 0) entity.popularity = popularity
  })
}

export async function getEntityBasicInfoByUri (uri: EntityUri) {
  const entities = await getEntitiesBasicInfoByUris([ uri ])
  return entities[uri]
}

export async function getEntitiesAttributesFromClaims (claims: Claims, attributes: GetEntitiesParams['attributes']) {
  if (!attributes) attributes = [ 'labels' ]
  const claimsValues = flatten(Object.values(claims))
  const uris = claimsValues.filter(isEntityUri)
  const { entities } = await getEntitiesAttributesByUris({
    uris,
    attributes,
    lang: mainUser.lang,
  })
  return entities
}

export function getWikidataUrl (uri: EntityUri) {
  const [ prefix, id ] = uri.split(':')
  if (prefix === 'wd') {
    return `https://www.wikidata.org/entity/${id}`
  }
}

export function getWikidataHistoryUrl (uri: EntityUri) {
  const [ prefix, id ] = uri.split(':')
  if (prefix === 'wd') {
    return `https://www.wikidata.org/w/index.php?title=${id}&action=history`
  }
}

export const getEntityLocalHref = (uri: EntityUri) => `/entity/${uri}`

const getSerieOrdinal = claims => claims['wdt:P1545']?.[0]

export function bySerieOrdinal (a, b) {
  return parseFloat(a.serieOrdinal || 10000) - parseFloat(b.serieOrdinal || 10000)
}

export function byPublicationDate (a, b) {
  // Ascendant order
  return parseInt(a.publicationYear || 10000) - parseInt(b.publicationYear || 10000)
}

export function byNewestPublicationDate (a, b) {
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

export function getPublicationYear (entity: Entity) {
  const date = entity.claims['wdt:P577']?.[0]
  return getYearFromSimpleDay(date)
}

export function getYearFromSimpleDay (date) {
  if (!date) return
  if (date[0] === '-') {
    const year = date.split('-')[1]
    return `-${year}`
  } else {
    return date.split('-')[0]
  }
}

export async function getEntitiesImages (uris: EntityUri[]) {
  if (uris.length === 0) return {}
  const { images } = await preq.get(API.entities.images(uris))
  return images
}

export async function getEntityImage (uri: EntityUri) {
  const images = getEntitiesImages([ uri ])
  return images[uri]
}
export async function getEntitiesImagesUrls (uris: EntityUri[]) {
  const images = await getEntitiesImages(uris)
  return extractImagesUrls(images)
}

export async function getEntityImageUrl (uri: EntityUri) {
  const imagesUrls = await getEntitiesImagesUrls([ uri ])
  return imagesUrls[0]
}

export function extractImagesUrls (images) {
  const imageUrls = Object.values(images).map(entityImages => {
    const firstImage = getBestLangValue(mainUser.lang, null, entityImages).value
    if (firstImage) return getEntityImagePath(firstImage)
  })
  return compact(imageUrls)
}

export function getEntityImagePath (imageValue) {
  if (isImageHash(imageValue)) return `/img/entities/${imageValue}`
  else return imageValue
}

export function hasLocalLayer (entity: SerializedEntity) {
  return entity.invUri != null
}

export function getClaimValue (claim) {
  return claim.value != null ? claim.value : claim
}

export const getPluralType = type => type + 's'

export async function getCollectionsPublishers (collectionsUris: EntityUri[]) {
  const entities = await getEntitiesList({ uris: collectionsUris, attributes: [ 'claims' ] })
  return flatten(entities.map(entity => entity.claims['wdt:P123']))
}

export async function getEditionsWorks (editions: SerializedEntity[]) {
  const uris = editions.map(getEditionWorksUris).flat()
  return getEntities(uris)
}

function getEditionWorksUris (edition: SerializedEntity) {
  const editionWorksUris = edition.claims['wdt:P629']
  if (edition.type !== 'edition') return []
  if (editionWorksUris == null) {
    const { uri } = edition
    const err = newError('edition entity misses associated works (wdt:P629)', { uri })
    throw err
  }
  return editionWorksUris
}

export async function getWorkEditions (workUri: EntityUri, params: Omit<GetEntitiesAttributesByUrisParams, 'uris'> = {}) {
  const { refresh = false } = params
  const uris = await getReverseClaims('wdt:P629', workUri, refresh)
  return getEntitiesList({ uris, ...params })
}

export async function addClaim <P extends keyof ClaimValueByProperty, T extends ClaimValueByProperty[P]> (entity: SerializedEntity, property: P, newValue: T) {
  const { uri } = entity
  try {
    entity.claims[property] ??= []
    // @ts-expect-error
    entity.claims[property].push(newValue)
    await preq.put(API.entities.claims.update, {
      uri,
      property,
      'old-value': null,
      'new-value': newValue,
    })
  } catch (err) {
    // @ts-expect-error
    entity.claims[property] = without(entity.claims[property], newValue)
    throw err
  }
  return serializeEntity(entity)
}

export async function updateClaim <P extends keyof ClaimValueByProperty, T extends ClaimValueByProperty[P]> (entity: SerializedEntity, property: P, oldValue: T, newValue: T) {
  const { uri } = entity
  try {
    entity.claims[property] = entity.claims[property].map(value => value === oldValue ? newValue : value)
    await preq.put(API.entities.claims.update, {
      uri,
      property,
      'old-value': oldValue,
      'new-value': newValue,
    })
  } catch (err) {
    entity.claims[property] = entity.claims[property].map(value => value === newValue ? oldValue : value)
    throw err
  }
  return serializeEntity(entity)
}

export async function updateLabel (uri: EntityUri, lang: WikimediaLanguageCode, value: string) {
  return preq.put(API.entities.labels.update, { uri, lang, value })
}

export async function removeLabel (uri: EntityUri, lang: WikimediaLanguageCode) {
  return preq.put(API.entities.labels.remove, { uri, lang })
}
