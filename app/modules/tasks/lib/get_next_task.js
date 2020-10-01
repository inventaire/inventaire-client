import Task from '../models/task'

const backlogs = {
  byScore: [],
  byAuthor: []
}

const suggestionUrisFetched = []

const limit = 10
let offset = 0

export default function (params = {}) {
  const { lastTaskModel } = params

  if (lastTaskModel != null) {
    if (backlogs.byAuthor.length !== 0) { return Promise.resolve(nextTaskModel('byAuthor')) }
    const suggestionUri = lastTaskModel.get('suggestionUri')
    if (!suggestionUrisFetched.includes(suggestionUri)) { return getNextTaskBySuggestionUri(params) }
  }

  return getNextTaskByScore(params)
};

const getNextTaskBySuggestionUri = function (params) {
  const { lastTaskModel, previousTasks } = params
  const suggestionUri = lastTaskModel.get('suggestionUri')

  return _.preq.get(app.API.tasks.bySuggestionUris(suggestionUri))
  .get('tasks')
  .get(suggestionUri)
  .filter(removePreviousTasks(previousTasks))
  .then(tasks => {
    suggestionUrisFetched.push(suggestionUri)
    if (tasks.length === 0) { return getNextTaskByScore(params) }
    return updateBacklogAndGetNextTask(tasks, 'byAuthor')
  })
}

const getNextTaskByScore = function (params) {
  let previousTasks
  if (backlogs.byScore.length !== 0) { return Promise.resolve(nextTaskModel('byScore')) }
  ({ offset, previousTasks } = params)

  // If an offset isn't specified, use a random offset between 0 and 500
  // to allow several contributors to work with the bests tasks at the same time
  // while having a low risk of conflicting
  if (offset == null) { offset = Math.trunc(Math.random() * 500) }

  return _.preq.get(app.API.tasks.byScore(limit, offset))
  .get('tasks')
  .filter(removePreviousTasks(previousTasks))
  .then(tasks => {
    offset += tasks.length
    return updateBacklogAndGetNextTask(tasks, 'byScore')
  })
}

const removePreviousTasks = previousTasks => task => !previousTasks.includes(task._id)

const updateBacklogAndGetNextTask = function (tasks, backlogName) {
  backlogs[backlogName].push(...Array.from(tasks || []))
  return nextTaskModel(backlogName)
}

const nextTaskModel = function (backlogName) {
  const backlog = backlogs[backlogName]
  const model = new Task(backlog.shift())
  return model
}
