Task = require '../models/task'

backlogs =
  byScore: []
  byAuthor: []

suggestionUrisFetched = []

limit = 10
offset = 0

module.exports = (params = {})->
  { lastTaskModel } = params

  if lastTaskModel?
    if backlogs.byAuthor.length isnt 0 then return _.preq.resolve nextTaskModel('byAuthor')
    suggestionUri = lastTaskModel.get 'suggestionUri'
    unless suggestionUri in suggestionUrisFetched then return getNextTaskBySuggestionUri params

  return getNextTaskByScore params

getNextTaskBySuggestionUri = (params)->
  { lastTaskModel, previousTasks } = params
  suggestionUri = lastTaskModel.get 'suggestionUri'

  _.preq.get app.API.tasks.bySuggestionUris(suggestionUri)
  .get 'tasks'
  .get suggestionUri
  .filter removePreviousTasks(previousTasks)
  .then (tasks)->
    suggestionUrisFetched.push suggestionUri
    return updateBacklogAndGetNextTask tasks, 'byAuthor'

getNextTaskByScore = (params)->
  if backlogs.byScore.length isnt 0 then return _.preq.resolve nextTaskModel('byScore')
  { offset, previousTasks } = params

  # If an offset isn't specified, use a random offset between 0 and 500
  # to allow several contributors to work with the bests tasks at the same time
  # while having a low risk of conflicting
  offset ?= Math.trunc(Math.random() * 500)

  _.preq.get app.API.tasks.byScore(limit, offset)
  .get 'tasks'
  .filter removePreviousTasks(previousTasks)
  .then (tasks)->
    offset += tasks.length
    return updateBacklogAndGetNextTask tasks, 'byScore'

removePreviousTasks = (previousTasks)-> (task)-> task._id not in previousTasks

updateBacklogAndGetNextTask = (tasks, backlogName)->
  backlogs[backlogName].push tasks...
  return nextTaskModel backlogName

nextTaskModel = (backlogName)->
  backlog = backlogs[backlogName]
  model = new Task backlog.shift()
  if backlogName is 'byAuthor'
    model.remainingAuthorTasksCount = backlog.length
  return model
