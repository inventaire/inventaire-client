import typeOf from '#lib/type_of'
// Keep in sync with server/lib/boolean_tests

import * as regex_ from '#lib/regex'

const isCouchUuid = regex_.CouchUuid.test.bind(regex_.CouchUuid)
const bindedTest = regexName => regex_[regexName].test.bind(regex_[regexName])

export const isNonEmptyString = str => _.isString(str) && (str.length > 0)

export const isUrl = url => {
  try {
    const { protocol, username, password } = new URL(url)
    if (!(protocol === 'http:' || protocol === 'https:')) return false
    if (username !== '' || password !== '') return false
  } catch (err) {
    // On the server, only err.code === 'ERR_INVALID_URL' returns false
    // and other errors are rethrown, but in the browser
    // err.code might be inconsistent
    // Ex: in Firefox 97, the error is "TypeError: URL constructor: bla is not a valid URL."
    return false
  }
  return true
}

export const isImageHash = bindedTest('ImageHash')
export const isLocalImg = bindedTest('LocalImg')
export const isAssetImg = bindedTest('AssetImg')
export const isUserImg = bindedTest('UserImg')
export const isGroupImg = bindedTest('GroupImg')
export const isInvEntityId = isCouchUuid
export const isEmail = bindedTest('Email')
export const isUserId = isCouchUuid
export const isGroupId = isCouchUuid
export const isItemId = isCouchUuid
export const isShelfId = isCouchUuid
export const isUsername = bindedTest('Username')
export const isEntityUri = bindedTest('EntityUri')
export const isPropertyUri = bindedTest('PropertyUri')

export function isExtendedEntityUri (uri) {
  const [ prefix, id ] = uri.split(':')
  // Accept alias URIs.
  // Ex: twitter:Bouletcorp -> wd:Q1524522
  return isNonEmptyString(prefix) && isNonEmptyString(id)
}

export const isWikidataItemId = bindedTest('WikidataItemId')
export const isWikidataPropertyId = bindedTest('WikidataPropertyId')
export const isWikidataItemUri = bindedTest('WikidataItemUri')
export const isWikidataPropertyUri = bindedTest('WikidataPropertyUri')

export const isNonNull = obj => obj != null

export const isNonEmptyArray = array => _.isArray(array) && (array.length > 0)

export const isPlainObject = obj => typeOf(obj) === 'object'
export const isNonEmptyPlainObject = obj => isPlainObject(obj) && Object.keys(obj).length > 0

export const isPositiveIntegerString = str => _.isString(str) && /^[1-9]\d*$/.test(str)

export const isModel = obj => obj instanceof Backbone.Model
export const isView = obj => obj instanceof Backbone.View

export const isDataUrl = str => /^data:image/.test(str)

export const isDateString = dateString => {
  if ((dateString == null) || (typeof dateString !== 'string')) return false
  return /^-?\d{4}(-\d{2})?(-\d{2})?$/.test(dateString)
}

// As Svelte components are the only known users of CustomEvent
// in the stack, it doesn't not need to be more specific than that for now
export const isComponentEvent = obj => obj instanceof CustomEvent
