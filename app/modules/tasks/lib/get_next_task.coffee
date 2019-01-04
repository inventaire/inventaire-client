Task = require '../models/task'

backlog = []
limit = 10
offset = 0

module.exports = (params = {})->
  if backlog.length isnt 0 then return _.preq.resolve nextTaskModel()
  { offset, previousTasks } = params

  # If an offset isn't specified, use a random offset between 0 and 500
  # to allow several contributors to work with the bests tasks at the same time
  # while having a low risk of conflicting
  offset ?= Math.trunc(Math.random() * 500)

  _.preq.get app.API.tasks.byScore(limit, offset)
  .get 'tasks'
  .filter (task)-> task._id not in previousTasks
  .then (tasks)->
    offset += tasks.length
    backlog.push tasks...
    return nextTaskModel()

nextTaskModel = -> new Task backlog.shift()
