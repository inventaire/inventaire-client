import { forceArray } from '#lib/utils'
import endpoint from './endpoint.js'
const { action } = endpoint('entities')

const CustomQuery = actionName => (uri, refresh) => action(actionName, { uri, refresh })

export default {
  // GET
  getByUris (uris, refresh, relatives) {
    uris = forceArray(uris).join('|')
    const autocreate = true
    if (relatives != null) relatives = forceArray(relatives).join('|')
    return action('by-uris', { uris, refresh, relatives, autocreate })
  },

  getAttributesByUris ({ uris, attributes, lang, relatives }) {
    const query = {
      uris: forceArray(uris).join('|')
    }
    if (attributes) {
      query.attributes = forceArray(attributes).join('|')
    }
    if (lang) {
      query.lang = lang
    }
    if (relatives != null) query.relatives = forceArray(relatives).join('|')
    return action('by-uris', query)
  },

  // Get many by POSTing URIs in the body
  getManyByUris: action('by-uris'),

  reverseClaims (property, value, refresh, sort) {
    return action('reverse-claims', { property, value, refresh, sort })
  },

  authorWorks: CustomQuery('author-works'),
  serieParts: CustomQuery('serie-parts'),
  publisherPublications: CustomQuery('publisher-publications'),

  images (uris, refresh) {
    uris = forceArray(uris).join('|')
    return action('images', { uris, refresh })
  },

  usersContributionsCount: period => action('contributions-count', { period }),

  changes: action('changes'),
  history: id => action('history', { id }),

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
  contributions ({ userId, limit, offset, filter }) {
    return action('contributions', { user: userId, limit, offset, filter })
  },
  moveToWikidata: action('move-to-wikidata')
}
