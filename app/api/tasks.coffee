{ action, base } = require('./endpoint')('tasks')

module.exports =
  base: base
  byScore: action 'by-score'
  collect: action 'collect-entities'
  update: action 'update'
