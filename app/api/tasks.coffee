{ action } = require('./endpoint')('tasks')

module.exports =
  byScore: action 'by-score'
