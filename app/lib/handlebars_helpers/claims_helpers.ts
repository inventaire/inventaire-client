import Handlebars from 'handlebars/runtime.js'
import { last, compact } from 'underscore'
import app from '#app/app'
import { isEntityUri } from '#app/lib/boolean_tests'
import { newError } from '#app/lib/error'
import entityValue from '#general/views/behaviors/templates/entity_value.hbs'
import propertyValue from '#general/views/behaviors/templates/property_value.hbs'
import { isWikidataItemId, isWikidataPropertyId, isWikidataPropertyUri } from '../boolean_tests.ts'

// @ts-expect-error
const { SafeString, escapeExpression } = Handlebars

export const prop = function (uri) {
  // Be more restrictive on the input to be able to use it in SafeStrings
  if (isWikidataPropertyUri(uri)) {
    // @ts-expect-error
    return propertyValue({ uri })
  } else if (isWikidataPropertyId(uri)) {
    // @ts-expect-error
    return propertyValue({ uri: `wdt:${uri}` })
  }
}

export const entity = function (uri, entityLink, alt?, property?, title?) {
  // Be restricting on the input to be able to use it in SafeStrings
  let pathname
  if (!isWikidataItemId(uri) && !isEntityUri(uri)) {
    throw newError('invalid entity uri', 500, { uri })
  }

  if (typeof alt !== 'string') alt = ''
  app.execute('uriLabel:update')
  alt = escapeExpression(alt)

  if ((property == null) || propertyWithSpecialLayout.includes(property)) {
    pathname = `/entity/${uri}`
  } else {
    pathname = `/entity/${property}-${uri}`
  }
  // @ts-expect-error
  return entityValue({ uri, pathname, entityLink, alt, label: alt, title })
}

const propertyWithSpecialLayout = [
  'wdt:P50', // author
  'wdt:P179', // serie
  'wdt:P361', // part of (serie)
  'wdt:P629', // work
  'wdt:P123', // publisher
  'wdt:P195', // collection
  'wdt:P155', // preceded by (work)
  'wdt:P156', // followed by (work)
  'wdt:P737', // influenced by (human)
  'wdt:P1066', // student of (human)
]

// handlebars pass a sometime confusing {data:, hash: object} as last argument
// this method is used to make helpers less error-prone by removing this object
export function neutralizeDataObject (args) {
  const lastArg = last(args)
  if ((lastArg?.hash != null) && (lastArg.data != null)) {
    return args.slice(0, -1)
  } else {
    return args
  }
}

export function getValuesTemplates (valueArray, entityLink, property) {
  // prevent any null value to sneak in
  return compact(valueArray)
  .map(uri => entity(uri, entityLink, null, property, null).trim())
  .join(', ')
}

export function labelString (pid, omitLabel) {
  return omitLabel ? '' : `${prop(pid)} `
}

export function claimString (label, values, inline?) {
  let text = `${label} ${values}`
  if (!inline) text += ' <br>'
  return new SafeString(text)
}
