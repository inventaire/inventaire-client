import endpoint from './endpoint'
const { action } = endpoint('entities')

const CustomQuery = actionName => (uri, refresh) => action(actionName, { uri, refresh })

export default {
  // GET
  getByUris (uris, refresh, relatives) {
    uris = _.forceArray(uris).join('|')
    if (relatives != null) { relatives = _.forceArray(relatives).join('|') }
    return action('by-uris', { uris, refresh, relatives })
  },

  // Get many by POSTing URIs in the body
  getManyByUris: action('by-uris'),

  reverseClaims (property, value, refresh, sort) {
    return action('reverse-claims', { property, value, refresh, sort })
  },

  authorWorks: CustomQuery('author-works'),
  serieParts: CustomQuery('serie-parts'),
  publisherPublications: CustomQuery('publisher-publications'),

  activity (period) { return action('activity', { period }) },
  changes: action('changes'),
  history (id) { return action('history', { id }) },

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
  delete: action('delete'),
  duplicates: action('duplicates'),
  contributions (userId, limit, offset) {
    return action('contributions', { user: userId, limit, offset })
  },
  moveToWikidata: action('move-to-wikidata')
}
