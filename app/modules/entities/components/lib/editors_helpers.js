import wdLang from 'wikidata-lang'
const { byCode: langByCode } = wdLang

export function alphabeticallySortedEntries (obj) {
  return Object.entries(obj)
  .sort((a, b) => a[0] > b[0] ? 1 : -1)
}

export const getNativeLangName = code => langByCode[code]?.native

export function getPropertyClaimsCount (propertyClaims) {
  return propertyClaims
  .filter(isNonEmptyClaimValue)
  .length
}

export function isEmptyClaimValue (value) {
  return value === null || value === Symbol.for('removed')
}

export const isNonEmptyClaimValue = value => !isEmptyClaimValue(value)
