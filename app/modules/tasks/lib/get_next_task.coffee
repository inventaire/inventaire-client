Task = require '../models/task'

backlog = []
limit = 10
offset = 0

module.exports = ->
  if backlog.length isnt 0 then return _.preq.resolve nextTaskModel()

  _.preq.get app.API.tasks.byScore(limit, offset)
  .get 'tasks'
  .then (tasks)->
    offset += tasks.length
    backlog.push tasks...
    return nextTaskModel()

nextTaskModel = -> new Task backlog.pop()
