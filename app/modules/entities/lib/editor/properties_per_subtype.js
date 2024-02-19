import { isNonEmptyArray } from '#lib/boolean_tests'
import { getUriNumericId } from '#lib/wikimedia/wikidata'
import { uniq } from 'underscore'

const mostlyTextWorksRoles = [
  'wdt:P50', // author
  'wdt:P98', // editor
  'wdt:P110', // illustrator
]

// Sorted by display order
const drawedWorksRoles = [
  'wdt:P58', // scenarist
  'wdt:P10837', // penciller
  'wdt:P6338', // colorist
  'wdt:P9191', // letterer
  'wdt:P10836', // inker
]

export const authorRoleProperties = mostlyTextWorksRoles.concat(drawedWorksRoles)
export const authorRolePropertiesSet = new Set(authorRoleProperties)

const preferredAuthorRolesPropertiesPerWorkType = {
  // works
  'wd:Q1004': drawedWorksRoles, // comics
  'wd:Q8274': drawedWorksRoles, // manga
  'wd:Q562214': drawedWorksRoles, // manhwa
  'wd:Q725377': drawedWorksRoles, // graphic novel
  'wd:Q747381': drawedWorksRoles, // light novel

  // series
  'wd:Q14406742': drawedWorksRoles, // comic book series
  'wd:Q21198342': drawedWorksRoles, // manga series
  'wd:Q74262765': drawedWorksRoles, // manhwa series
  'wd:Q104213567': drawedWorksRoles, // light novel series
}

export function getWorkPreferredAuthorRolesProperties (entity) {
  const P31 = entity.claims['wdt:P31'] || []
  const preferredAuthorRolesProperties = P31.flatMap(getP31PreferredAuthorRolesProperties)
  const usedAuthorRolesProperties = authorRoleProperties.filter(property => isNonEmptyArray(entity.claims[property]))
  return uniq(preferredAuthorRolesProperties.concat(usedAuthorRolesProperties)).sort(byNumericId)
}

const byNumericId = (a, b) => getUriNumericId(a) - getUriNumericId(b)

function getP31PreferredAuthorRolesProperties (P31value) {
  return preferredAuthorRolesPropertiesPerWorkType[P31value] || mostlyTextWorksRoles
}
