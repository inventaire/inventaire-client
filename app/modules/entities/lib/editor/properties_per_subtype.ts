import { uniq } from 'underscore'
import { isNonEmptyArray } from '#app/lib/boolean_tests'

const mostlyTextWorksRoles = [
  'wdt:P50', // author
  'wdt:P98', // editor
  'wdt:P110', // illustrator
]

// See https://github.com/inventaire/inventaire/issues/765
const manga = [
  'wdt:P50', // author
  'wdt:P110', // illustrator
  'wdt:P10837', // penciller
]

// Sorted by display order
const drawnWorksRoles = [
  'wdt:P58', // scenarist
  'wdt:P10837', // penciller
  'wdt:P6338', // colorist
  'wdt:P9191', // letterer
  'wdt:P10836', // inker
]

export const authorRoleProperties = mostlyTextWorksRoles.concat(drawnWorksRoles)
export const authorRolePropertiesSet = new Set(authorRoleProperties)

const preferredAuthorRolesPropertiesPerWorkType = {
  // works
  'wd:Q1004': drawnWorksRoles, // comics
  'wd:Q8274': manga, // manga
  'wd:Q562214': drawnWorksRoles, // manhwa
  'wd:Q725377': drawnWorksRoles, // graphic novel

  // series
  'wd:Q14406742': drawnWorksRoles, // comic book series
  'wd:Q21198342': manga, // manga series
  'wd:Q74262765': drawnWorksRoles, // manhwa series
}

export function getWorkPreferredAuthorRolesProperties (entity) {
  const P31 = entity.claims['wdt:P31'] || []
  const preferredAuthorRolesProperties = P31.flatMap(getP31PreferredAuthorRolesProperties)
  const usedAuthorRolesProperties = authorRoleProperties.filter(property => isNonEmptyArray(entity.claims[property]))
  return uniq(preferredAuthorRolesProperties.concat(usedAuthorRolesProperties)).sort(byDisplayOrder)
}

const byDisplayOrder = (a, b) => authorRoleProperties.indexOf(a) - authorRoleProperties.indexOf(b)

function getP31PreferredAuthorRolesProperties (P31value) {
  return preferredAuthorRolesPropertiesPerWorkType[P31value] || mostlyTextWorksRoles
}
