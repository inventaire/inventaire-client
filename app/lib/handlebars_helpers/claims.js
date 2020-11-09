import { isEntityUri } from 'lib/boolean_tests'
import typeOf from 'lib/type_of'
import { i18n } from 'modules/user/lib/i18n'
import * as icons_ from './icons'
import wdLang from 'wikidata-lang'
import commons_ from 'lib/wikimedia/commons'
import linkify_ from './linkify'
import platforms_ from './platforms'
import {
  prop as propHelper,
  entity as entityHelper,
  neutralizeDataObject,
  getValuesTemplates,
  labelString,
  claimString
} from './claims_helpers'
import Handlebars from 'handlebars/runtime'
const { SafeString, escapeExpression } = Handlebars

let API

export default API = {
  prop: propHelper,
  entity: entityHelper,
  claim (...args) {
    // entityLink: set to true to link to the entity layout (work, author, etc),
    // the alternative being to link to a claim_layout
    const [ claims, prop, entityLink, omitLabel, inline ] = neutralizeDataObject(args)
    if (claims?.[prop]?.[0] != null) {
      const label = labelString(prop, omitLabel)
      const values = getValuesTemplates(claims[prop], entityLink, prop)
      return claimString(label, values, inline)
    }
  },

  timeClaim (...args) {
    let [ claims, prop, format, omitLabel, inline ] = neutralizeDataObject(args)
    // default to 'year' and override handlebars data object when args.length is 3
    format = format || 'year'
    if (claims?.[prop]?.[0] != null) {
      let values = claims[prop]
        .map(unixTime => {
          const time = new Date(unixTime)
          if (format === 'year') return time.getUTCFullYear()
        })
        .filter(isntNaN)
      const label = labelString(prop, omitLabel)
      values = _.uniq(values).join(` ${i18n('or')} `)
      return claimString(label, values, inline)
    }
  },

  imageClaim (claims, prop, omitLabel, inline, data) {
    if (claims?.[prop]?.[0] != null) {
      const file = claims[prop][0]
      const src = commons_.thumbnail(file, 200)
      const propClass = prop.replace(':', '-')
      return new SafeString(`<img class='image-claim ${propClass}' src='${src}'>`)
    }
  },

  stringClaim (...args) {
    const [ claims, prop, omitLabel, inline ] = neutralizeDataObject(args)
    if (claims?.[prop]?.[0] != null) {
      const label = labelString(prop, omitLabel)
      const values = escapeExpression(claims[prop]?.join(', '))
      return claimString(label, values, inline)
    }
  },

  urlClaim (...args) {
    const [ claims, prop ] = neutralizeDataObject(args)
    const firstUrl = claims?.[prop]?.[0]
    if (firstUrl != null) {
      const label = icons_.icon('link')
      const cleanedUrl = removeTailingSlash(dropProtocol(firstUrl))
      const values = linkify_(cleanedUrl, firstUrl, 'link website')
      return claimString(label, values)
    }
  },

  platformClaim (...args) {
    const [ claims, prop ] = neutralizeDataObject(args)
    const firstPlatformId = claims?.[prop]?.[0]
    if (firstPlatformId != null) {
      const platform = platforms_[prop]
      const icon = icons_.icon(platform.icon)
      const escapedText = escapeExpression(platform.text(firstPlatformId))
      const text = icon + '<span>' + escapedText + '</span>'
      const url = platform.url(firstPlatformId)
      const values = linkify_(text, url, 'link social-network')
      return claimString('', values)
    }
  },

  entityRemoteHref (uri) {
    const [ prefix, id ] = uri.split(':')
    switch (prefix) {
    case 'wd': return `https://www.wikidata.org/entity/${id}`
    default: return API.entityLocalHref(uri)
    }
  },

  entityLocalHref (uri) { return `/entity/${uri}` },
  claimLocalHref (propertyUri, entityUri) { return `/entity/${propertyUri}-${entityUri}` },

  multiTypeValue (value) {
    switch (typeOf(value)) {
    case 'string':
      if (isEntityUri(value)) {
        return entityHelper(value, true)
      } else {
        return escapeExpression(value)
      }
    case 'array': return value.map(API.multiTypeValue).join('')
    case 'object': return escapeExpression(JSON.stringify(value))
    }
  },

  entityFromLang (lang) {
    const langEntityId = wdLang.byCode[lang]?.wd
    if (langEntityId != null) {
      return new SafeString(entityHelper(`wd:${langEntityId}`, false))
    } else {
      return lang
    }
  }
}

const dropProtocol = url => url.replace(/^(https?:)?\/\//, '')
const removeTailingSlash = url => url.replace(/\/$/, '')
const isntNaN = value => !_.isNaN(value)
