import { forceArray } from 'lib/utils'
import endpoint from './endpoint'
import { customizeInstance } from './instance'
const { action } = endpoint('entities')

const CustomQuery = actionName => (uri, refresh) => customizeInstance(action(actionName, { uri, refresh }))

export default {
  // GET
  getByUris (uris, refresh, relatives) {
    uris = forceArray(uris).join('|')
    const autocreate = true
    if (relatives != null) relatives = forceArray(relatives).join('|')
    const url = action('by-uris', { uris, refresh, relatives, autocreate })
    return customizeInstance(url)
  },

  // Get many by POSTing URIs in the body
  getManyByUris: () => customizeInstance(action('by-uris')),

  reverseClaims (property, value, refresh, sort) {
    return customizeInstance(action('reverse-claims', { property, value, refresh, sort }))
  },

  authorWorks: CustomQuery('author-works'),
  serieParts: CustomQuery('serie-parts'),
  publisherPublications: CustomQuery('publisher-publications'),

  images (uris, refresh) {
    uris = forceArray(uris).join('|')
    return customizeInstance(action('images', { uris, refresh }))
  },

  activity: period => customizeInstance(action('activity', { period })),
  changes: action('changes'),
  history: id => customizeInstance(action('history', { id })),

  // POST
  create: action('create'),
  resolve: action('resolve'),

  // PUT
  claims: {
    update: action('update-claim')
  },

  labels: {
    update: action('update-label')
  },

  merge: action('merge'),

  revertEdit: action('revert-edit'),

  delete: action('delete'),
  duplicates: action('duplicates'),
  contributions (userId, limit, offset) {
    return customizeInstance(action('contributions', { user: userId, limit, offset }))
  },
  moveToWikidata: action('move-to-wikidata')
}
