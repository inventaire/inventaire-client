import { union, pick, uniq } from 'underscore'
import wdLang from 'wikidata-lang'
import { isNonEmptyArray } from '#app/lib/boolean_tests'
import { icon as iconFn } from '#app/lib/icons'
import { unprefixify } from '#app/lib/wikimedia/wikidata'
import type { SerializedEntity } from '#entities/lib/entities'
import { platforms } from '#entities/lib/platforms'
import type { AuthorProperty } from '#entities/lib/properties'
import { isStandaloneEntityType, typeDefaultP31 } from '#entities/lib/types/entities_types'

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

export const propertiesByRoles: Record<string, AuthorProperty[]> = {
  // The keys order determines the display order in AuthorsInfo
  editor: [ 'wdt:P98' ],
  author: [ 'wdt:P50' ],
  scenarist: [ 'wdt:P58' ],
  illustrator: [ 'wdt:P110' ],
  penciller: [ 'wdt:P10837' ],
  colorist: [ 'wdt:P6338' ],
  letterer: [ 'wdt:P9191' ],
  inker: [ 'wdt:P10836' ],
} as const

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
  return pick(worksClaims, isNonEmptyArray)
}

export const propertiesType = {
  'wdt:P577': 'timeClaim',
  'wdt:P856': 'urlClaim',
  'wdt:P953': 'urlClaim',
  'wdt:P1581': 'urlClaim',
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
  'wdt:P655': 'editions_translated_by_author',
  'wdt:P674': 'character_in',
  'wdt:P737': 'authors_influenced_by',
  'wdt:P840': 'narrative_set_in_this_location',
  'wdt:P921': 'works_about_entity',
  'wdt:P941': 'works_inspired_by_work',
  'wdt:P1433': 'published_in',
  'wdt:P2675': 'works_replying_to_work',
  'wdt:P2679,wdt:P2680': 'editions_prefaced_or_postfaced_by_author',
  'wdt:P7937': 'works_in_this_form',
} as const

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
    return unixTime.getUTCFullYear()
  }
  return value
}

export function urlClaim (params) {
  return removeTailingSlash(dropProtocol(params.value))
}

export function platformClaim (params) {
  const { prop, value } = params
  const platform = platforms[prop]
  const icon = iconFn(platform.icon)
  const text = icon + '<span>' + platform.text(value) + '</span>'
  const url = platform.url(value)
  return { icon, text, url }
}

const claimFormats = {
  timeClaim,
  urlClaim,
  platformClaim,
}

const aggregateClaims = (worksClaims, work) => {
  editionWorkProperties.forEach(aggregateClaim(worksClaims, work))
  return worksClaims
}

const aggregateClaim = (worksClaims, work) => prop => {
  const claimValues = work.claims[prop]
  // list of unique items
  if (claimValues) worksClaims[prop] = union(worksClaims[prop], claimValues)
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

const workAndSeriesPropertiesByType = [
  ...authorsProps,
  'wdt:P577', // publication date
  'wdt:P179', // series
  'wdt:P7937', // form of creative work
  'wdt:P136', // genre
  'wdt:P921', // main subject
]

export const infoboxShortlistPropertiesByType = {
  edition: [
    'wdt:P577', // publication date
    'wdt:P123', // publisher
    'wdt:P195', // collection
    'wdt:P212', // ISBN-13
  ],
  human: [
    'wdt:P742', // pseudonym
    'wdt:P135', // movement
    'wdt:P27', // country of citizenship
    'wdt:P1412', // language of expression
    'wdt:P69', // educated at
    'wdt:P106', // occupation
  ],
  work: workAndSeriesPropertiesByType,
  serie: workAndSeriesPropertiesByType,
}

const websites = [
  'wdt:P856', // official website
  'wdt:P1581', // official blog URL
]

const workProperties = [
  ...authorsProps,
  'wdt:P577', // publication date
  'wdt:P7937', // form of creative work
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
  ...websites,
]

export const infoboxPropertiesByType = {
  edition: [
    'wdt:P2679', // author of foreword
    'wdt:P2680', // author of afterword
    'wdt:P655', // translator
    'wdt:P577', // publication date
    'wdt:P123', // publisher
    'wdt:P195', // collection
    'wdt:P1104', // number of pages
    'wdt:P212', // ISBN-13
    'wdt:P957', // ISBN-10
    'wdt:P629', // edition or translation of
    'wdt:P2635', // number of volumes
    ...websites,
    'wdt:P407', // edition language
  ],
  work: workProperties,
  serie: workProperties,
  human: [
    'wdt:P742', // pseudonym
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
    ...websites,
  ],
  publisher: [
    'wdt:P571', // inception
    'wdt:P576', // dissolution
    'wdt:P112', // founded by
    'wdt:P127', // owned by
    ...websites,
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
    'wdt:P407', // language
    ...websites,
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

export const defaultWorkP31PerSerieP31 = {
  'wd:Q1667921': 'wd:Q7725634', // novel
  'wd:Q14406742': 'wd:Q1004', // comic book
  'wd:Q21198342': 'wd:Q8274', // manga
  'wd:Q74262765': 'wd:Q562214', // manhwa
  'wd:Q104213567': 'wd:Q747381', // light novel
}

export function getDefaultWorkP31FromSerie (serie: SerializedEntity) {
  const P31Value = serie.claims['wdt:P31'][0]
  return defaultWorkP31PerSerieP31[P31Value] || typeDefaultP31.work
}
