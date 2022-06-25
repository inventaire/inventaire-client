import { isNonEmptyArray } from '#lib/boolean_tests'
import wdLang from 'wikidata-lang'
import { unprefixify } from '#lib/wikimedia/wikidata'
import platforms_ from '#lib/handlebars_helpers/platforms.js'
import * as icons_ from '#lib/handlebars_helpers/icons.js'

export const formatClaimValue = params => {
  const { value, propType, prop } = params
  if (propType && claimFormats[propType]) {
    return claimFormats[propType](params)
  } else if (prop && propertiesType[prop]) {
    const type = propertiesType[prop]
    return claimFormats[type](params)
  } else {
    // TODO: sanitize value ? (known types: String, Number)
    return value
  }
}

export const getWorkProperties = omitAuthors => {
  // propertiesPerType.work doesnt seem to have enough props available
  // ie. original title, narrative location, characters
  let props = [
    'wdt:P50', // author
    'wdt:P58', // scenarist
    'wdt:P110', // illustrator
    'wdt:P6338', // colorist
    'wdt:P577', // publication date
    'wdt:P136', // genre
    'wdt:P361', // part of (serie)
    'wdt:P179', // series
    'wdt:P1545', // series ordinal
    'wdt:P1476', // title
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

export function getLang (entity) {
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
      'wdt:P1680', // subtitle
      'wdt:P577', // publication date
      'wdt:P123', // publisher
      'wdt:P212', // ISBN-13
      'wdt:P179', // series
    ],
    long: [
      'wdt:P1680', // edition subtitle
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
      'wdt:P179', // series
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
  }
}
