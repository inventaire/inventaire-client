Task = require '../models/task'

backlog = []
limit = 10
offset = 0

module.exports = (params = {})->
  if backlog.length isnt 0 then return _.preq.resolve nextTaskModel()
  { previousTasks } = params

  _.preq.get app.API.tasks.byScore(limit, offset)
  .get 'tasks'
  .filter (task)-> task._id not in previousTasks
  .then (tasks)->
    offset += tasks.length
    backlog.push tasks...
    return nextTaskModel()

nextTaskModel = -> new Task backlog.shift()
