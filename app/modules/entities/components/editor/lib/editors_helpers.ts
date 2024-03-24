import error_ from '#lib/error'
import { i18n } from '#user/lib/i18n'
import { writable } from 'svelte/store'
import wdLang from 'wikidata-lang'
const { byCode: langByCode } = wdLang

export function alphabeticallySortedEntries (obj) {
  return Object.entries(obj)
  .sort((a, b) => a[0] > b[0] ? 1 : -1)
}

export const getNativeLangName = code => langByCode[code]?.native

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

export const isNonEmptyClaimValue = value => !isEmptyClaimValue(value)

export function addClaimValue (propertyClaims = [], value) {
  if (!propertyClaims.includes(value)) {
    propertyClaims.push(value)
  }
  return propertyClaims
}

export const currentEditorKey = writable(null)

export function errorMessageFormatter (err) {
  if (err.message === 'this property value is already used') {
    const uri = err.responseJSON.context.entity
    err.html = `${i18n(err.message)}: <a href="/entity/${uri}" class="link">${uri}</a>`
  }
  if (err.statusCode === 413) {
    const cause = err
    err = error_.new('image is too big', 413)
    if (cause.stack) err.stack = cause.stack
    err.cause = cause
  }
  return err
}
