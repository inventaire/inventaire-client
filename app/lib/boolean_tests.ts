import { isString, isArray } from 'underscore'
import * as regex_ from '#lib/regex'
import typeOf from '#lib/type_of'
import type { AbsoluteUrl } from '#server/types/common'
import type { CouchUuid } from '#server/types/couchdb'
import type { EntityUri, PropertyUri, WdEntityUri, WdPropertyUri } from '#server/types/entity'
import type { AssetImagePath, ImageDataUrl, GroupImagePath, ImageHash, ImagePath, UserImagePath } from '#server/types/image'
import type { Email, Username } from '#server/types/user'
import type { ItemId, PropertyId } from 'wikibase-sdk'

function bindedTest <T> (regexName) {
  return function (str): str is T {
    return regex_[regexName].test(str)
  }
}

export const isNonEmptyString = str => isString(str) && (str.length > 0)

export function isUrl (url: string): url is AbsoluteUrl {
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

export const isCouchUuid = bindedTest<CouchUuid>('CouchUuid')
export const isImageHash = bindedTest<ImageHash>('ImageHash')
export const isLocalImg = bindedTest<ImagePath>('LocalImg')
export const isAssetImg = bindedTest<AssetImagePath>('AssetImg')
export const isUserImg = bindedTest<UserImagePath>('UserImg')
export const isGroupImg = bindedTest<GroupImagePath>('GroupImg')
export const isInvEntityId = isCouchUuid
export const isEmail = bindedTest<Email>('Email')
export const isUserId = isCouchUuid
export const isGroupId = isCouchUuid
export const isItemId = isCouchUuid
export const isShelfId = isCouchUuid
export const isUsername = bindedTest<Username>('Username')
export const isEntityUri = bindedTest<EntityUri>('EntityUri')
export const isPropertyUri = bindedTest<PropertyUri>('PropertyUri')
export const isWikidataItemId = bindedTest<ItemId>('WikidataItemId')
export const isWikidataPropertyId = bindedTest<PropertyId>('WikidataPropertyId')
export const isWikidataItemUri = bindedTest<WdEntityUri>('WikidataItemUri')
export const isWikidataPropertyUri = bindedTest<WdPropertyUri>('WikidataPropertyUri')

export const isNonNull = obj => obj != null

export const isNonEmptyArray = array => isArray(array) && (array.length > 0)

export const isPlainObject = obj => typeOf(obj) === 'object'
export const isNonEmptyPlainObject = obj => isPlainObject(obj) && Object.keys(obj).length > 0

export const isPositiveIntegerString = str => isString(str) && /^[1-9]\d*$/.test(str)

export const isModel = obj => obj instanceof Backbone.Model
export const isView = obj => obj instanceof Backbone.View

export function isImageDataUrl (str: string): str is ImageDataUrl {
  return /^data:image/.test(str)
}

export const isDateString = dateString => {
  if ((dateString == null) || (typeof dateString !== 'string')) return false
  return /^-?\d{4}(-\d{2})?(-\d{2})?$/.test(dateString)
}

// As Svelte components are the only known users of CustomEvent
// in the stack, it doesn't not need to be more specific than that for now
export function isComponentEvent (obj): obj is CustomEvent {
  return obj instanceof CustomEvent
}
