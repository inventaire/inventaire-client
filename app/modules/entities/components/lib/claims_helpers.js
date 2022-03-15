import {
  labelString,
  getValuesTemplates,
  claimString,
} from '#lib/handlebars_helpers/claims_helpers'
import linkify_ from '#lib/handlebars_helpers/linkify'
import { icon } from '#lib/utils'
import { i18n } from '#user/lib/i18n'
import { isNonEmptyArray } from '#lib/boolean_tests'

const omitLabel = false

export const formatClaim = params => {
  const { prop, values, omitLabel } = params
  if (!isNonEmptyArray(values)) return
  const type = propertiesType[prop]
  if (!type) return
  return claimFormats[type]({ values, prop, omitLabel })
}

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
  'wdt:P179': 'entityClaim',
  'wdt:P195': 'entityClaim',
  'wdt:P212': 'stringClaim',
  'wdt:P407': 'entityClaim',
  'wdt:P577': 'timeClaim',
  'wdt:P629': 'entityClaim',
  'wdt:P655': 'entityClaim',
  'wdt:P856': 'urlClaim',
  'wdt:P1104': 'stringClaim',
  'wdt:P2635': 'stringClaim',
  'wdt:P2679': 'entityClaim',
  'wdt:P2680': 'entityClaim',
  'wdt:P6338': 'entityClaim',
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
