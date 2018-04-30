{ action } = require('./endpoint')('tasks')

module.exports =
  byScore: action 'by-score'
  update: action 'update'
