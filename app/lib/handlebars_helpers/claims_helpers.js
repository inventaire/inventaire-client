/* eslint-disable
    import/no-duplicates,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import entityValue from 'modules/general/views/behaviors/templates/entity_value'
import propertyValue from 'modules/general/views/behaviors/templates/property_value'
import wdk from 'lib/wikidata-sdk'
import error_ from 'lib/error'
const { SafeString, escapeExpression } = Handlebars

const prop = function (uri) {
  // Be more restrictive on the input to be able to use it in SafeStrings
  if (/^wdt:P\d+$/.test(uri)) {
    return propertyValue({ uri })
  } else if (wdk.isWikidataPropertyId(uri)) { return propertyValue({ uri: `wdt:${uri}` }) }
}

const entity = function (uri, entityLink, alt, property, title) {
  // Be restricting on the input to be able to use it in SafeStrings
  let pathname
  if (!wdk.isWikidataItemId(uri) && !_.isEntityUri(uri)) {
    throw error_.new('invalid entity uri', 500, { uri })
  }

  if (typeof alt !== 'string') { alt = '' }
  app.execute('uriLabel:update')
  alt = escapeExpression(alt)

  if ((property == null) || propertyWithSpecialLayout.includes(property)) {
    pathname = `/entity/${uri}`
  } else {
    pathname = `/entity/${property}-${uri}`
  }

  return entityValue({ uri, pathname, entityLink, alt, label: alt, title })
}

var propertyWithSpecialLayout = [
  'wdt:P50', // author
  'wdt:P179', // serie
  'wdt:P629', // work
  'wdt:P123', // publisher
  'wdt:P195', // collection
  'wdt:P155', // preceded by (work)
  'wdt:P156', // followed by (work)
  'wdt:P737', // influenced by (human)
  'wdt:P1066' // student of (human)
]

export default {
  prop,
  entity,
  // handlebars pass a sometime confusing {data:, hash: object} as last argument
  // this method is used to make helpers less error-prone by removing this object
  neutralizeDataObject (args) {
    const last = _.last(args)
    if ((last?.hash != null) && (last.data != null)) {
      return args.slice(0, -1)
    } else { return args }
  },

  getValuesTemplates (valueArray, entityLink, property) {
    // prevent any null value to sneak in
    return _.compact(valueArray)
    .map(uri => entity(uri, entityLink, null, property).trim())
    .join(', ')
  },

  labelString (pid, omitLabel) {
    if (omitLabel) { return '' } else { return prop(pid) }
  },

  claimString (label, values, inline) {
    let text = `${label} ${values}`
    if (!inline) { text += ' <br>' }
    return new SafeString(text)
  }
}
