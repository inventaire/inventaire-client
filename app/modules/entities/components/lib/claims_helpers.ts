import Handlebars from 'handlebars/runtime.js'
import { uniq } from 'underscore'
import wdLang from 'wikidata-lang'
import { isStandaloneEntityType } from '#entities/lib/types/entities_types'
import { isEntityUri, isImageHash, isNonEmptyArray } from '#lib/boolean_tests'
import { imagePreview } from '#lib/handlebars_helpers/claims'
import { entity as entityHelper } from '#lib/handlebars_helpers/claims_helpers'
import * as icons_ from '#lib/handlebars_helpers/icons.ts'
import platforms_ from '#lib/handlebars_helpers/platforms.ts'
import typeOf from '#lib/type_of'
import { unprefixify } from '#lib/wikimedia/wikidata'

const { escapeExpression } = Handlebars

export const formatClaimValue = params => {
  const { value, prop } = params
  const propType = propertiesType[prop]
  if (propType && claimFormats[propType]) {
    return claimFormats[propType](params)
  } else if (prop && propertiesType[prop]) {
    const type = propertiesType[prop]
    return claimFormats[type](params)
  } else {
    return value
  }
}

export const propertiesByRoles = {
  author: [ 'wdt:P50' ],
  scenarist: [ 'wdt:P58' ],
  illustrator: [ 'wdt:P110' ],
  colorist: [ 'wdt:P6338' ],
  letterer: [ 'wdt:P9191' ],
  inker: [ 'wdt:P10836' ],
  penciller: [ 'wdt:P10837' ],
}

export const authorsProps = Object.values(propertiesByRoles).flat()

export const relativeEntitiesListsProps = [
  'wdt:P737', // influenced by
]

export const editionWorkProperties = [
  ...authorsProps,
  'wdt:P179', // serie
]

export const aggregateWorksClaims = works => {
  const worksClaims = editionWorkProperties.map(value => ({ [value]: [] }))
  works.reduce(aggregateClaims, worksClaims)
  return _.pick(worksClaims, isNonEmptyArray)
}

export const propertiesType = {
  'wdt:P577': 'timeClaim',
  'wdt:P856': 'urlClaim',
  'wdt:P953': 'urlClaim',
  'wdt:P2034': 'platformClaim',
  'wdt:P724': 'platformClaim',
  'wdt:P4258': 'platformClaim',
}

export const buildPathname = (entity, prop) => {
  const { uri, type } = entity

  if (isStandaloneEntityType(type)) {
    return `/entity/${uri}`
  }
  if (!specialPathnameProperties.includes(prop)) prop = 'wdt:P921'
  return `/entity/${prop}-${uri}`
}

export const inverseLabels = {
  // Hardcoding as a make-it-work implementation for translation purposes (not to be updated too often).
  'wdt:P69': 'educated_at',
  'wdt:P135': 'associated_with_this_movement',
  'wdt:P136': 'works_in_this_genre',
  'wdt:P144': 'works_based_on_work',
  'wdt:P2675': 'works_replying_to_work',
  'wdt:P655': 'editions_translated_by_author',
  'wdt:P674': 'character_in',
  'wdt:P737': 'authors_influenced_by',
  'wdt:P840': 'narrative_set_in_this_location',
  'wdt:P921': 'works_about_entity',
  'wdt:P941': 'works_inspired_by_work',
  'wdt:P1433': 'published_in',
}

const specialPathnameProperties = Object.keys(inverseLabels)

export function timeClaim (params) {
  const { value, format } = params
  if (format && format === 'year') {
    const splittedDate = value.split('-')
    // Display before christ values with year precision only
    // Convert -427-05-07 to -427
    if (value.startsWith('-')) {
      return `-${splittedDate[1]}`
    }
    const year = splittedDate[0]
    let unixTime = new Date(year)
    if (year < 1000) {
      unixTime = new Date('0000')
      unixTime.setFullYear(year)
    }
    return unixTime.getUTCFullYear(year)
  }
  return value
}

export function urlClaim (params) {
  return removeTailingSlash(dropProtocol(params.value))
}

export function platformClaim (params) {
  const { prop, value } = params
  const platform = platforms_[prop]
  const icon = icons_.icon(platform.icon)
  const text = icon + '<span>' + platform.text(value) + '</span>'
  const url = platform.url(value)
  return { icon, text, url }
}

const claimFormats = {
  timeClaim,
  urlClaim,
  platformClaim,
}

// TODO: reimplement without handlebars
export function multiTypeValue (value) {
  const valueType = typeOf(value)
  if (valueType === 'string') {
    if (isEntityUri(value)) {
      return entityHelper(value, true)
    } else if (isImageHash(value)) {
      return imagePreview(value)
    } else {
      return escapeExpression(value)
    }
  } else if (valueType === 'number') {
    return value
  } else if (valueType === 'array') {
    return value.map(multiTypeValue).join('')
  } else if (valueType === 'object') {
    return escapeExpression(JSON.stringify(value))
  }
}

const aggregateClaims = (worksClaims, work) => {
  editionWorkProperties.forEach(aggregateClaim(worksClaims, work))
  return worksClaims
}

const aggregateClaim = (worksClaims, work) => prop => {
  const claimValues = work.claims[prop]
  // list of unique items
  if (claimValues) worksClaims[prop] = _.union(worksClaims[prop], claimValues)
}

const removeTailingSlash = url => url.replace(/\/$/, '')
const dropProtocol = url => url.replace(/^(https?:)?\/\//, '')

export const getEntityPropValue = (entity, prop) => {
  const claimValues = entity?.claims[prop]
  if (claimValues) return claimValues[0]
}

export function getEntityLang (entity) {
  const langUri = getEntityPropValue(entity, 'wdt:P407')
  return langUri ? wdLang.byWdId[unprefixify(langUri)]?.code : undefined
}

export const hasSelectedLang = selectedLangs => edition => {
  const { originalLang } = edition
  if (originalLang !== undefined) return selectedLangs.includes(originalLang)
}

export const infoboxShortlistPropertiesByType = {
  edition: [
    'wdt:P577', // publication date
    'wdt:P123', // publisher
    'wdt:P195', // collection
    'wdt:P212', // ISBN-13
  ],
  work: [
    ...authorsProps,
    'wdt:P577', // publication date
    'wdt:P179', // series
    'wdt:P136', // genre
    'wdt:P921', // main subject
  ],
  human: [
    'wdt:P135', // movement
    'wdt:P136', // genre
    'wdt:P27', // country of citizenship
    'wdt:P1412', // language of expression
    'wdt:P69', // educated at
    'wdt:P106', // occupation
  ],
}
infoboxShortlistPropertiesByType.serie = infoboxShortlistPropertiesByType.work

const workProperties = [
  ...authorsProps,
  'wdt:P577', // publication date
  'wdt:P136', // genre
  'wdt:P361', // part of (serie)
  'wdt:P179', // series
  'wdt:P1545', // series ordinal
  'wdt:P1476', // title
  'wdt:P407', // edition language
  'wdt:P1680', // subtitle
  'wdt:P144', // based on
  'wdt:P2675', // reply to
  'wdt:P941', // inspired by
  'wdt:P135', // movement
  'wdt:P921', // main subject
  'wdt:P840', // narrative location
  'wdt:P674', // characters
  'wdt:P1433', // published in
  'wdt:P155', // preceded by
  'wdt:P156', // followed by
]

export const infoboxPropertiesByType = {
  edition: [
    'wdt:P2679', // author of foreword
    'wdt:P2680', // author of afterword
    'wdt:P655', // translator
    'wdt:P577', // publication date
    'wdt:P123', // publisher
    'wdt:P1104', // number of pages
    'wdt:P212', // ISBN-13
    'wdt:P957', // ISBN-10
    'wdt:P629', // edition or translation of
    'wdt:P195', // collection
    'wdt:P2635', // number of volumes
    'wdt:P856', // official website
    'wdt:P407', // edition language
  ],
  work: workProperties,
  serie: workProperties,
  human: [
    'wdt:P135', // movement
    'wdt:P136', // genre
    'wdt:P27', // country of citizenship
    'wdt:P103', // native language
    'wdt:P1412', // language of expression
    'wdt:P69', // educated at
    'wdt:P106', // occupation
    'wdt:P166', // award received
    'wdt:P39', // position held
    'wdt:P1066', // student of
    'wdt:P737', // influenced by
    'wdt:P856', // official website
  ],
  publisher: [
    'wdt:P571', // inception
    'wdt:P576', // dissolution
    'wdt:P112', // founded by
    'wdt:P127', // owned by
    'wdt:P856', // official website
    'wdt:P407', // language
    'wdt:P136', // genre
    'wdt:P921', // subject
  ],
  collection: [
    'wdt:P123', // publisher
    'wdt:P571', // inception
    'wdt:P98', // editor
    'wdt:P112', // founded by
    'wdt:P127', // owned by
    'wdt:P856', // official website
    'wdt:P921', // subject
  ],
  article: [
    'wdt:P1433', // published in
    'wdt:P577', // publication date
    'wdt:P407', // language
    'wdt:P921', // subject
  ],
}

export const formatYearClaim = (dateProp, claims) => {
  const values = claims[dateProp]
  return isNonEmptyArray(values) ? uniq(values.map(formatTime)) : ''
}

const formatTime = value => timeClaim({ value, format: 'year' })

export const formatEbooksClaim = (values, prop) => {
  if (!values) return
  return values.map(value => formatClaimValue({ prop, value }))
}
