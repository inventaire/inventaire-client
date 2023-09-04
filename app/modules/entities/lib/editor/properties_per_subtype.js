import { uniq } from 'underscore'

const classicBook = [ 'wdt:P50' ]
const illustratedBook = [ 'wdt:P58', 'wdt:P110', 'wdt:P6338' ]
// const collectiveBook = [ 'wdt:P50', 'wdt:P98' ]

const preferredAuthorRolesPropertiesPerWorkType = {
  'wd:Q1004': illustratedBook, // comics
  'wd:Q8274': illustratedBook, // manga
  'wd:Q562214': illustratedBook, // manhwa
  'wd:Q725377': illustratedBook, // graphic novel
  'wd:Q747381': illustratedBook, // light novel
}

export function getWorkPreferredAuthorRolesProperties (entity) {
  const P31 = entity.claims['wdt:P31'] || []
  const authorRolesProperties = uniq(P31.flatMap(getP31PreferredAuthorRolesProperties))
  return authorRolesProperties
}

function getP31PreferredAuthorRolesProperties (P31value) {
  return preferredAuthorRolesPropertiesPerWorkType[P31value] || classicBook
}
