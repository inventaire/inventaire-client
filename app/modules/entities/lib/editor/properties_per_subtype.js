import { isNonEmptyArray } from '#lib/boolean_tests'
import { getUriNumericId } from '#lib/wikimedia/wikidata'
import { uniq } from 'underscore'

const classicBook = [ 'wdt:P50' ]
const illustratedBook = [ 'wdt:P58', 'wdt:P110', 'wdt:P6338' ]
// const collectiveBook = [ 'wdt:P50', 'wdt:P98' ]
const allAuthorRoleProperties = classicBook.concat(illustratedBook)

const preferredAuthorRolesPropertiesPerWorkType = {
  // works
  'wd:Q1004': illustratedBook, // comics
  'wd:Q8274': illustratedBook, // manga
  'wd:Q562214': illustratedBook, // manhwa
  'wd:Q725377': illustratedBook, // graphic novel
  'wd:Q747381': illustratedBook, // light novel

  // series
  'wd:Q14406742': illustratedBook, // comic book series
  'wd:Q21198342': illustratedBook, // manga series
  'wd:Q74262765': illustratedBook, // manhwa series
  'wd:Q104213567': illustratedBook, // light novel series
}

export function getWorkPreferredAuthorRolesProperties (entity) {
  const P31 = entity.claims['wdt:P31'] || []
  const preferredAuthorRolesProperties = P31.flatMap(getP31PreferredAuthorRolesProperties)
  const usedAuthorRolesProperties = allAuthorRoleProperties.filter(property => isNonEmptyArray(entity.claims[property]))
  return uniq(preferredAuthorRolesProperties.concat(usedAuthorRolesProperties)).sort(byNumericId)
}

const byNumericId = (a, b) => getUriNumericId(a) - getUriNumericId(b)

function getP31PreferredAuthorRolesProperties (P31value) {
  return preferredAuthorRolesPropertiesPerWorkType[P31value] || classicBook
}
