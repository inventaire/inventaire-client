{ action } = require('./endpoint')('tasks')

module.exports =
  byIds: (ids)-> action 'by-ids', { ids }
  byScore: (limit, offset)-> action 'by-score', { limit, offset }
  bySuspectUri: (uri)-> action 'by-suspect-uri', { uri }
  update: action 'update'
