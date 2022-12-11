import { isNonEmptyArray } from '#lib/boolean_tests'
import wdLang from 'wikidata-lang'
import { unprefixify } from '#lib/wikimedia/wikidata'
import platforms_ from '#lib/handlebars_helpers/platforms.js'
import * as icons_ from '#lib/handlebars_helpers/icons.js'
import { uniq } from 'underscore'

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

export const getWorkProperties = omitAuthors => {
  // propertiesPerType.work doesnt seem to have enough props available
  // ie. original title, narrative location, characters
  let props = [
    'wdt:P577', // publication date
    'wdt:P136', // genre
    'wdt:P361', // part of (serie)
    'wdt:P179', // series
    'wdt:P1545', // series ordinal
    'wdt:P1476', // title
    'wdt:P407', // edition language
    'wdt:P1680', // subtitle
    'wdt:P144', // based on
    'wdt:P941', // inspired by
    'wdt:P135', // movement
    'wdt:P921', // main subject
    'wdt:P840', // narrative location
    'wdt:P674', // characters
    'wdt:P1433', // published in
    'wdt:P155', // preceded by
    'wdt:P156', // followed by
  ]
  if (!omitAuthors) props = [ ...authorsProps, ...props ]
  return props
}

export const authorsProps = [
  'wdt:P50', // author
  'wdt:P58', // scenarist
  'wdt:P110', // illustrator
  'wdt:P6338', // colorist
]

export const relativeEntitiesListsProps = [
  'wdt:P737' // influenced by
]

export const editionWorkProperties = [
  ...authorsProps,
  'wdt:P179', // serie
]

export const aggregateWorksClaims = works => {
  let worksClaims = editionWorkProperties.map(value => ({ [value]: [] }))
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
  const { uri } = entity
  if (specialPathnameProperties.includes(prop)) {
    return `/entity/${prop}-${uri}`
  }
  return `/entity/${uri}`
}

export const inverseLabels = {
  // Hardcoding as a make it work implmentation for translation purposes (not to be updated too often).
  // TODO: use the inverse label property (P7087) and wikidata-lang to generate translation
  'wdt:P135': 'associated_with_this_movement',
  'wdt:P136': 'works_in_this_genre',
  'wdt:P144': 'works_based_on_work',
  'wdt:P655': 'translator_of',
  'wdt:P674': 'character_in',
  'wdt:P737': 'authors_influenced_by',
  'wdt:P840': 'narrative_set_in_this_location',
  'wdt:P921': 'works_about_entity',
  'wdt:P941': 'works_inspired_by_work',
  'wdt:P1433': 'published_in',
  'wdt:P2679': 'prefaced_works',
  'wdt:P2680': 'postfaced_works',
}

const specialPathnameProperties = Object.keys(inverseLabels)

const claimFormats = {
  timeClaim (params) {
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
  },
  urlClaim (params) {
    return removeTailingSlash(dropProtocol(params.value))
  },
  platformClaim (params) {
    const { prop, value } = params
    const platform = platforms_[prop]
    const icon = icons_.icon(platform.icon)
    const text = icon + '<span>' + platform.text(value) + '</span>'
    const url = platform.url(value)
    return { icon, text, url }
  },
}

export const {
  timeClaim,
  urlClaim,
  platformClaim,
} = claimFormats

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

export const infoboxPropsLists = {
  edition: {
    short: [
      'wdt:P50', // author
      'wdt:P577', // publication date
      'wdt:P123', // publisher
      'wdt:P195', // collection
      'wdt:P212', // ISBN-13
    ],
    long: [
      ...authorsProps,
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
  },
  work: {
    short: [
      'wdt:P577', // publication date
      'wdt:P179', // series
      'wdt:P136', // genre
      'wdt:P921', // main subject
    ],
    long: getWorkProperties(),
  },
  serie: {
    short: [
      'wdt:P577', // publication date
      'wdt:P179', // series
      'wdt:P136', // genre
      'wdt:P921', // main subject
    ],
    long: getWorkProperties(),
  },
  human: {
    short: [
      'wdt:P135', // movement
      'wdt:P136', // genre
      'wdt:P27', // country of citizenship
      'wdt:P1412', // language of expression
      'wdt:P69', // educated at
      'wdt:P106', // occupation
    ],
    long: [
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
    ]
  },
  publisher: {
    short: [],
    long: [
      'wdt:P571', // inception
      'wdt:P576', // dissolution
      'wdt:P112', // founded by
      'wdt:P127', // owned by
    ],
  },
  collection: {
    short: [],
    long: [
      'wdt:P1680', // subtitle
      'wdt:P123', // publisher
      'wdt:P98', // editor
    ],
  }
}

infoboxPropsLists.serie = infoboxPropsLists.work

export const formatYearClaim = (dateProp, claims) => {
  const values = claims[dateProp]
  return isNonEmptyArray(values) ? uniq(values.map(formatTime)) : ''
}

const formatTime = value => timeClaim({ value, format: 'year' })

export const formatEbooksClaim = (values, prop) => {
  if (!values) return
  // TODO: handle multiple values in a selector
  return formatClaimValue({ prop, value: values[0] })
}
