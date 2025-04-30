import { writable } from 'svelte/store'
import { omit } from 'underscore'
import { newError } from '#app/lib/error'
import { objectEntries } from '#app/lib/utils'
import type { SerializedEntity } from '#entities/lib/entities'
import { i18n } from '#user/lib/i18n'
import type { WikimediaLanguageCode } from 'wikibase-sdk'

export function getEditableLabels (labels: SerializedEntity['labels']) {
  return omit(labels, 'fromclaims')
}

export function alphabeticallySortedEntries (labels: Partial<Record<WikimediaLanguageCode, string>>) {
  return objectEntries(labels)
  .sort((a, b) => a[0] > b[0] ? 1 : -1)
}

export function getNonEmptyPropertyClaims (propertyClaims = []) {
  return propertyClaims
  .filter(isNonEmptyClaimValue)
}

export function getPropertyClaimsCount (propertyClaims) {
  return getNonEmptyPropertyClaims(propertyClaims).length
}

export function isEmptyClaimValue (value) {
  return value === null || value === Symbol.for('removed') || value === Symbol.for('moved')
}

export const isNonEmptyClaimValue = value => value != null && !isEmptyClaimValue(value)

export function addClaimValue (propertyClaims = [], value) {
  if (!propertyClaims.includes(value)) {
    propertyClaims.push(value)
  }
  return propertyClaims
}

export const currentEditorKey = writable(null)

export function errorMessageFormatter (err) {
  if (err.message.includes('this property value is already used')) {
    const uri = err.responseJSON.context.entity
    err.html = `${i18n('this property value is already used')}: <a href="/entity/${uri}" class="link">${uri}</a>`
  }
  if (err.statusCode === 413) {
    const cause = err
    err = newError('image is too big', 413)
    if (cause.stack) err.stack = cause.stack
    err.cause = cause
  }
  return err
}
