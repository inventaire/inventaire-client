import { forceArray } from 'lib/utils'
import endpoint from './endpoint'
const { action } = endpoint('tasks')
const byEntitiesUris = name => uris => {
  uris = forceArray(uris).join('|')
  return action(`by-${name}-uris`, { uris })
}

export default {
  byIds (ids) { return action('by-ids', { ids }) },
  byScore (limit, offset) { return action('by-score', { limit, offset }) },
  byType (params) { return action('by-type', params) },
  bySuspectUris: byEntitiesUris('suspect'),
  bySuggestionUris: byEntitiesUris('suggestion'),
  deduplicateWork: action('deduplicate-work'),
  update: action('update')
}
