import {
  labelString,
  getValuesTemplates,
  claimString,
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

const farInTheFuture = '2100'
const omitLabel = false

export const formatClaim = params => {
  const { prop, values, omitLabel, inline } = params
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

export const aggregateWorksClaims = (claims, works) => {
  let worksClaims = editionWorkProperties.map(value => ({ [value]: [] }))
  works.reduce(aggregateClaims, worksClaims)
  return _.pick(worksClaims, isNonEmptyArray)
}

const propertiesType = {
  'wdt:P50': 'entityClaim',
  'wdt:P58': 'entityClaim',
  'wdt:P110': 'entityClaim',
  'wdt:P123': 'entityClaim',
  'wdt:P135': 'entityClaim',
  'wdt:P136': 'entityClaim',
  'wdt:P144': 'entityClaim',
  'wdt:P155': 'entityClaim',
  'wdt:P156': 'entityClaim',
  'wdt:P179': 'entityClaim',
  'wdt:P195': 'entityClaim',
  'wdt:P212': 'stringClaim',
  'wdt:P361': 'entityClaim',
  'wdt:P407': 'entityClaim',
  'wdt:P577': 'timeClaim',
  'wdt:P629': 'entityClaim',
  'wdt:P655': 'entityClaim',
  'wdt:P674': 'entityClaim',
  'wdt:P840': 'entityClaim',
  'wdt:P856': 'urlClaim',
  'wdt:P921': 'entityClaim',
  'wdt:P941': 'entityClaim',
  'wdt:P953': 'urlClaim',
  'wdt:P1104': 'stringClaim',
  'wdt:P1433': 'entityClaim',
  'wdt:P1476': 'stringClaim',
  'wdt:P1545': 'stringClaim',
  'wdt:P1680': 'stringClaim',
  'wdt:P2635': 'stringClaim',
  'wdt:P2679': 'entityClaim',
  'wdt:P2680': 'entityClaim',
  'wdt:P6338': 'entityClaim',
  'wdt:P2034': 'platformClaim',
  'wdt:P724': 'platformClaim',
  'wdt:P4258': 'platformClaim',
}

const claimFormats = {
  entityClaim: params => {
    const { prop, omitLabel } = params
    let { values } = params
    const entityLink = true
    const label = labelString(prop, omitLabel)
    values = getValuesTemplates(values, entityLink, prop)
    return claimString(label, values)
  },
  timeClaim (params) {
    const { prop } = params
    let { values, format } = params
    format = format || 'year'
    values.map(unixTime => {
      const time = new Date(unixTime)
      if (format === 'year') return time.getUTCFullYear()
    })
    const label = labelString(prop, omitLabel)
    values = _.uniq(values).join(` ${i18n('or')} `)
    return claimString(label, values)
  },
  stringClaim (params) {
    const { prop } = params
    let { values } = params
    const label = labelString(prop, omitLabel)
    return claimString(label, values)
  },
  urlClaim (params) {
    let { values } = params
    const label = icon('link')
    const firstUrl = values[0]
    const cleanedUrl = removeTailingSlash(dropProtocol(firstUrl))
    values = linkify_(cleanedUrl, firstUrl, 'link website')
    return claimString(label, values)
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
      const values = linkify_(text, url, 'link social-network')
      return claimString('', values)
    }
  },
}

export const { entityClaim: formatEntityClaim } = claimFormats

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

export function getTitle (entity) {
  return entity.claims['wdt:P1476'][0]
}

const getEntityPropValue = (entity, prop) => {
  const claimValues = entity.claims[prop]
  if (claimValues) return claimValues[0]
}

export const getIsbn = entity => getEntityPropValue(entity, 'wdt:P212')
export const getPublication = entity => getEntityPropValue(entity, 'wdt:P577')

export function getLang (entity) {
  const langUri = entity.claims['wdt:P407'][0]
  return langUri ? wdLang.byWdId[unprefixify(langUri)]?.code : undefined
}

export function getPublicationTime (entity) {
  const publicationDate = entity.claims['wdt:P577'][0]
  return new Date(publicationDate || farInTheFuture).getTime()
}

export function getPublicationDate (entity) {
  const publicationDate = entity.claims['wdt:P577'][0]
  if (publicationDate != null) {
    return parseInt(publicationDate.split('-')[0])
    // inPublicDomain = this.publicationYear < publicDomainThresholdYear
  }
}
