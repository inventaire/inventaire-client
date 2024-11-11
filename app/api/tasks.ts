import { forceArray } from '#app/lib/utils'
import { getEndpointPathBuilders } from './endpoint.ts'

const { action } = getEndpointPathBuilders('tasks')

export default {
  byIds (ids) { return action('by-ids', { ids }) },
  byScore (limit, offset) { return action('by-score', { limit, offset }) },
  byEntitiesType (params) { return action('by-entities-type', params) },
  bySuggestionUris (uris) {
    uris = forceArray(uris).join('|')
    return action('by-suggestion-uris', { uris })
  },
  deduplicateWorks: action('deduplicate-works'),
  update: action('update'),
  count: action('tasks-count'),
}
