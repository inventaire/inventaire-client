import {
  labelString,
} from '#lib/handlebars_helpers/claims_helpers'
import { propertiesPerType } from '#entities/lib/editor/properties_per_type'
import linkify_ from '#lib/handlebars_helpers/linkify'
import { icon } from '#lib/utils'
import { i18n } from '#user/lib/i18n'
import { isNonEmptyArray } from '#lib/boolean_tests'
import wdLang from 'wikidata-lang'
import { unprefixify } from '#lib/wikimedia/wikidata'
import platforms_ from '#lib/handlebars_helpers/platforms.js'
import * as icons_ from '#lib/handlebars_helpers/icons.js'

export const formatClaim = params => {
  const { prop, values, inline, omitLabel } = params
  if (values[0] === null) return
  const type = propertiesType[prop]
  if (!type) return
  return claimFormats[type]({ values, prop, omitLabel, inline })
}

// TODO: use propertiesPerType.work once commented props (ie. P840) are back in the object (needs some investigation on why its has been commented)
export const workProperties = [
  'wdt:P577',
  'wdt:P361',
  'wdt:P179',
  'wdt:P1545',
  'wdt:P1476',
  'wdt:P1680',
  'wdt:P407',
  'wdt:P144',
  'wdt:P941',
  'wdt:P136',
  'wdt:P135',
  'wdt:P921',
  'wdt:P840',
  'wdt:P674',
  'wdt:P1433',
  'wdt:P155',
  'wdt:P156',
]

export const editionProperties = Object.keys(propertiesPerType.edition)
export const editionWorkProperties = [
  'wdt:P50', // author
  'wdt:P58', // scenarist
  'wdt:P110', // illustrator
  'wdt:P6338', // colorist
  'wdt:P179', // serie
]

export const aggregateWorksClaims = works => {
  let worksClaims = editionWorkProperties.map(value => ({ [value]: [] }))
  works.reduce(aggregateClaims, worksClaims)
  return _.pick(worksClaims, isNonEmptyArray)
}

export const propertiesType = {
  'wdt:P50': 'entityProp',
  'wdt:P58': 'entityProp',
  'wdt:P110': 'entityProp',
  'wdt:P123': 'entityProp',
  'wdt:P135': 'entityProp',
  'wdt:P136': 'entityProp',
  'wdt:P144': 'entityProp',
  'wdt:P155': 'entityProp',
  'wdt:P156': 'entityProp',
  'wdt:P179': 'entityProp',
  'wdt:P195': 'entityProp',
  'wdt:P212': 'stringClaim',
  'wdt:P361': 'entityProp',
  'wdt:P407': 'entityProp',
  'wdt:P577': 'timeClaim',
  'wdt:P629': 'entityProp',
  'wdt:P655': 'entityProp',
  'wdt:P674': 'entityProp',
  'wdt:P840': 'entityProp',
  'wdt:P856': 'urlClaim',
  'wdt:P921': 'entityProp',
  'wdt:P941': 'entityProp',
  'wdt:P953': 'urlClaim',
  'wdt:P1104': 'stringClaim',
  'wdt:P1433': 'entityProp',
  'wdt:P1476': 'stringClaim',
  'wdt:P1545': 'stringClaim',
  'wdt:P1680': 'stringClaim',
  'wdt:P2635': 'stringClaim',
  'wdt:P2679': 'entityProp',
  'wdt:P2680': 'entityProp',
  'wdt:P6338': 'entityProp',
  'wdt:P2034': 'platformClaim',
  'wdt:P724': 'platformClaim',
  'wdt:P4258': 'platformClaim',
}

const claimFormats = {
  entityProp (params) {
    const { prop, omitLabel } = params
    let { values } = params
    const label = labelString(prop, omitLabel)
    return `${label}${values}`
  },
  timeClaim (params) {
    const { prop, omitLabel } = params
    let { values, format } = params
    format = format || 'year'
    values = values.map(unixTime => {
      const time = new Date(unixTime)
      if (format === 'year') { return time.getUTCFullYear() }
    })
    const label = labelString(prop, omitLabel)
    values = _.uniq(values).join(` ${i18n('or')} `)
    return `${label}${values}`
  },
  stringClaim (params) {
    const { prop, omitLabel } = params
    let { values } = params
    const label = labelString(prop, omitLabel)
    return `${label}${values}`
  },
  urlClaim (params) {
    let { values } = params
    const label = icon('link')
    const firstUrl = values[0]
    const cleanedUrl = removeTailingSlash(dropProtocol(firstUrl))
    values = linkify_(cleanedUrl, firstUrl, 'link website')
    return `${label}${values}`
  },
  platformClaim (params) {
    const { prop } = params
    let { values } = params
    const firstPlatformId = values[0]
    if (firstPlatformId != null) {
      const platform = platforms_[prop]
      const icon = icons_.icon(platform.icon)
      const text = icon + '<span>' + platform.text(firstPlatformId) + '</span>'
      const url = platform.url(firstPlatformId)
      return linkify_(text, url, 'link social-network')
    }
  },
}

export const {
  entityProp,
  timeClaim,
  stringClaim,
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

export function getPublicationDate (entity) {
  const publicationDate = getEntityPropValue(entity, 'wdt:P577')
  if (publicationDate === null) return {}
  const publicationYear = parseInt(publicationDate.split('-')[0])
  const inPublicDomain = publicationYear < publicDomainThresholdYear
  return { publicationYear, inPublicDomain }
}

const publicDomainThresholdYear = new Date().getFullYear() - 70

export const hasSelectedLang = selectedLangs => edition => {
  const { originalLang } = edition
  if (originalLang !== undefined) return selectedLangs.includes(originalLang)
}

export const editionShortlist = [
  'wdt:P1680', // subtitle
  'wdt:P577', // publication date
  'wdt:P123', // publisher
  'wdt:P212', // isbn 13
  'wdt:P179', // serie
]

export const editionLonglist = [
  'wdt:P2679', // author of foreword
  'wdt:P2680', // author of afterword
  'wdt:P655', // translator
  'wdt:P577', // publication date
  'wdt:P1104', // number of pages
  'wdt:P123', // publisher
  'wdt:P212', // ISBN-13
  'wdt:P957', // ISBN-10
  'wdt:P629', // edition or translation of
  'wdt:P195', // collection
  'wdt:P2635', // number of volumes
  'wdt:P856', // official website
  'wdt:P1476', // edition title
  'wdt:P1680', // edition subtitle
  'wdt:P407', // edition language
  'wdt:P179', // series
]

export const removeFromList = (list, el) => {
  const index = list.indexOf(el)
  if (index >= 0) list.splice(index, 1)
}
