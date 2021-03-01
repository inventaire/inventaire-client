import preq from 'lib/preq'
import Task from '../models/task'

const backlogs = {
  byScore: [],
  byAuthor: [],
  byWork: []
}

const suggestionUrisFetched = []

const limit = 10
let offset = 0

export default function (params = {}) {
  return getNextTask(params)
}

const getNextTask = async params => {
  const { entitiesType } = params
  let nextTaskGetter = ''
  if (entitiesType === 'work') {
    params.backlogType = 'byWork'
    nextTaskGetter = 'byWork'
  } else {
    params.backlogType = 'byAuthor'
    nextTaskGetter = 'byScore'
  }

  const { lastTaskModel } = params
  if (lastTaskModel != null) {
    if (backlogs.byWork.length !== 0) { return Promise.resolve(getNextTaskModel(params.backlogType)) }
    const suggestionUri = lastTaskModel.get('suggestionUri')
    if (!suggestionUrisFetched.includes(suggestionUri)) return getNextTaskBySuggestionUri(params)
  }
  if (backlogs.byWork.length !== 0) return getNextTaskModel(nextTaskGetter)
  const { previousTasks } = params
  offset = params.offset

  // If an offset isn't specified, use a random offset between 0 and 500
  // to allow several contributors to work with the bests humans tasks at the same time
  // while having a low risk of conflicting
  // (only for human tasks as there are not that many work tasks)
  if (offset == null && entitiesType === 'human') offset = Math.trunc(Math.random() * 500)

  // Predictable behavior in development environment
  if (window.env === 'dev') offset = 0

  let { tasks } = await requestNewTasks(entitiesType, limit, offset)
  tasks = tasks.filter(removePreviousTasks(previousTasks))
  offset += tasks.length
  return updateBacklogAndGetNextTask(tasks, nextTaskGetter)
}

const getNextTaskBySuggestionUri = async params => {
  const { lastTaskModel, previousTasks } = params
  const suggestionUri = lastTaskModel.get('suggestionUri')

  const { tasks } = await preq.get(app.API.tasks.bySuggestionUris(suggestionUri))
  let suggestionUriTasks = tasks[suggestionUri]
  suggestionUriTasks = suggestionUriTasks.filter(removePreviousTasks(previousTasks))
  suggestionUrisFetched.push(suggestionUri)
  if (suggestionUriTasks.length === 0) return getNextTask(params)
  else return updateBacklogAndGetNextTask(suggestionUriTasks, params.backlogType)
}

const requestNewTasks = async (type, limit, offset) => {
  if (type === 'work') {
    return preq.get(app.API.tasks.byEntitiesType({ type, limit, offset }))
  } else {
    return preq.get(app.API.tasks.byScore(limit, offset))
  }
}
const removePreviousTasks = previousTasks => task => !previousTasks.includes(task._id)

const updateBacklogAndGetNextTask = (tasks = [], backlogName) => {
  backlogs[backlogName].push(...tasks)
  return getNextTaskModel(backlogName)
}

const getNextTaskModel = backlogName => {
  const backlog = backlogs[backlogName]
  if (backlog.length === 0) return
  const model = new Task(backlog.shift())
  return model
}
