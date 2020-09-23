/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
const { action } = require('./endpoint')('tasks')
const byEntitiesUris = name => function (uris) {
  uris = _.forceArray(uris).join('|')
  return action(`by-${name}-uris`, { uris })
}

export default {
  byIds (ids) { return action('by-ids', { ids }) },
  byScore (limit, offset) { return action('by-score', { limit, offset }) },
  bySuspectUris: byEntitiesUris('suspect'),
  bySuggestionUris: byEntitiesUris('suggestion'),
  update: action('update')
}
