import preq from 'lib/preq'
import Task from '../models/task'

const backlogs = {
  byScore: [],
  byAuthor: []
}

const suggestionUrisFetched = []

const limit = 10
let offset = 0

export default async function (params = {}) {
  const { lastTaskModel } = params

  if (lastTaskModel != null) {
    if (backlogs.byAuthor.length !== 0) return getNextTaskModel('byAuthor')
    const suggestionUri = lastTaskModel.get('suggestionUri')
    if (!suggestionUrisFetched.includes(suggestionUri)) return getNextTaskBySuggestionUri(params)
  }

  return getNextTaskByScore(params)
}

const getNextTaskBySuggestionUri = async params => {
  const { lastTaskModel, previousTasks } = params
  const suggestionUri = lastTaskModel.get('suggestionUri')

  const { tasks } = await preq.get(app.API.tasks.bySuggestionUris(suggestionUri))
  let suggestionUriTasks = tasks[suggestionUri]
  suggestionUriTasks = suggestionUriTasks.filter(removePreviousTasks(previousTasks))
  suggestionUrisFetched.push(suggestionUri)
  if (suggestionUriTasks.length === 0) return getNextTaskByScore(params)
  else return updateBacklogAndGetNextTask(suggestionUriTasks, 'byAuthor')
}

const getNextTaskByScore = async params => {
  if (backlogs.byScore.length !== 0) return getNextTaskModel('byScore')
  const { previousTasks } = params
  offset = params.offset

  // If an offset isn't specified, use a random offset between 0 and 500
  // to allow several contributors to work with the bests tasks at the same time
  // while having a low risk of conflicting
  if (offset == null) offset = Math.trunc(Math.random() * 500)

  let { tasks } = await preq.get(app.API.tasks.byScore(limit, offset))
  tasks = tasks.filter(removePreviousTasks(previousTasks))
  offset += tasks.length
  return updateBacklogAndGetNextTask(tasks, 'byScore')
}

const removePreviousTasks = previousTasks => task => !previousTasks.includes(task._id)

const updateBacklogAndGetNextTask = function (tasks = [], backlogName) {
  backlogs[backlogName].push(...tasks)
  return getNextTaskModel(backlogName)
}

const getNextTaskModel = function (backlogName) {
  const backlog = backlogs[backlogName]
  const model = new Task(backlog.shift())
  return model
}
