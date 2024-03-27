import { forceArray } from '#lib/utils'
import { getEndpointPathBuilders } from './endpoint.ts'

const { action } = getEndpointPathBuilders('tasks')
const byEntitiesUris = name => uris => {
  uris = forceArray(uris).join('|')
  return action(`by-${name}-uris`, { uris })
}

export default {
  byIds (ids) { return action('by-ids', { ids }) },
  byScore (limit, offset) { return action('by-score', { limit, offset }) },
  byEntitiesType (params) { return action('by-entities-type', params) },
  bySuspectUris: byEntitiesUris('suspect'),
  bySuggestionUris: byEntitiesUris('suggestion'),
  deduplicateWorks: action('deduplicate-works'),
  update: action('update'),
}
