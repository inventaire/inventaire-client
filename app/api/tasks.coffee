{ action } = require('./endpoint')('tasks')
byEntitiesUris = (name)-> (uris)->
  uris = _.forceArray(uris).join '|'
  return action "by-#{name}-uris", { uris }

module.exports =
  byIds: (ids)-> action 'by-ids', { ids }
  byScore: (limit, offset)-> action 'by-score', { limit, offset }
  bySuspectUris:  byEntitiesUris 'suspect'
  bySuggestionUris:  byEntitiesUris 'suggestion'
  update: action 'update'
