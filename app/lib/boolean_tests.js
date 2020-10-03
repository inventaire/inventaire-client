// Keep in sync with server/lib/boolean_tests

import * as regex_ from 'lib/regex'

const isCouchUuid = regex_.CouchUuid.test.bind(regex_.CouchUuid)
const bindedTest = regexName => regex_[regexName].test.bind(regex_[regexName])

const isNonEmptyString = str => _.isString(str) && (str.length > 0)

export default {
  isUrl: bindedTest('Url'),
  isImageHash: bindedTest('ImageHash'),
  isLocalImg: bindedTest('LocalImg'),
  isAssetImg: bindedTest('AssetImg'),
  isUserImg: bindedTest('UserImg'),
  isInvEntityId: isCouchUuid,
  isEmail: bindedTest('Email'),
  isUserId: isCouchUuid,
  isGroupId: isCouchUuid,
  isItemId: isCouchUuid,
  isShelfId: isCouchUuid,
  isUsername: bindedTest('Username'),
  isEntityUri: bindedTest('EntityUri'),
  isExtendedEntityUri (uri) {
    const [ prefix, id ] = Array.from(uri.split(':'))
    // Accept alias URIs.
    // Ex: twitter:Bouletcorp -> wd:Q1524522
    return isNonEmptyString(prefix) && isNonEmptyString(id)
  },
  isPropertyUri: bindedTest('PropertyUri'),

  isNonNull (obj) { return (obj != null) },
  isNonEmptyString,
  isNonEmptyArray (array) { return _.isArray(array) && (array.length > 0) },
  isNonEmptyPlainObject (obj) {
    return _.isPlainObject(obj) && (Object.keys(obj).length > 0)
  },
  isPositiveIntegerString (str) { return _.isString(str) && /^[1-9]\d*$/.test(str) },
  isPlainObject (obj) { return _.typeOf(obj) === 'object' },
  isModel (obj) { return obj instanceof Backbone.Model },
  isView (obj) { return obj instanceof Backbone.View },
  isCanvas (obj) { return obj?.nodeName?.toLowerCase() === 'canvas' }
}
