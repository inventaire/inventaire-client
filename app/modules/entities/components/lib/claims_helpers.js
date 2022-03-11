import {
  labelString,
  getValuesTemplates,
  claimString,
} from '#lib/handlebars_helpers/claims_helpers'
import linkify_ from '#lib/handlebars_helpers/linkify'
import { icon } from '#lib/utils'
import { i18n } from '#user/lib/i18n'

const omitLabel = false

export const formatClaim = (prop, claims) => {
  let values = claims[prop]
  if (values[0] === null) return ''
  const type = propertiesType[prop]
  if (!type) return ''
  return claimFormats[type](values, prop)
}

export const propertiesType = {
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
  entityClaim: (values, prop) => {
    const entityLink = true
    const label = labelString(prop, omitLabel)
    values = getValuesTemplates(values, entityLink, prop)
    return claimString(label, values)
  },
  timeClaim (values, prop, format) {
    format = format || 'year'
    values.map(unixTime => {
      const time = new Date(unixTime)
      if (format === 'year') return time.getUTCFullYear()
    })
    const label = labelString(prop, omitLabel)
    values = _.uniq(values).join(` ${i18n('or')} `)
    return claimString(label, values)
  },
  stringClaim (values, prop) {
    const label = labelString(prop, omitLabel)
    return claimString(label, values)
  },
  urlClaim (values, prop) {
    const label = icon('link')
    const firstUrl = values[0]
    const cleanedUrl = removeTailingSlash(dropProtocol(firstUrl))
    values = linkify_(cleanedUrl, firstUrl, 'link website')
    return claimString(label, values)
  },
}
const removeTailingSlash = url => url.replace(/\/$/, '')
const dropProtocol = url => url.replace(/^(https?:)?\/\//, '')
