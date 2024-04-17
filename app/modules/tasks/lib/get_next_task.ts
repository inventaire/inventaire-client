import app from '#app/app'
import { isNonEmptyArray } from '#app/lib/boolean_tests'
import preq from '#app/lib/preq'

const backlogs = {
  byScore: [],
  bySuggestion: [],
  byWork: [],
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
    params.backlogName = 'byWork'
    nextTaskGetter = 'byWork'
  } else {
    params.backlogName = 'bySuggestion'
    nextTaskGetter = 'byScore'
  }

  const { lastTask } = params
  if (lastTask != null) {
    // prioritize byAuthor over byScore
    if (areTasksInBacklog(params.backlogName)) return shiftTaskFromBacklog(params.backlogName)
    // prioritize task with same suggestion
    const suggestionUri = lastTask.suggestionUri
    if (!suggestionUrisFetched.includes(suggestionUri)) return getNextTaskBySuggestionUri(params)
  }
  if (areTasksInBacklog(nextTaskGetter)) return shiftTaskFromBacklog(nextTaskGetter)
  const { previousTasksIds } = params

  // If an offset isn't specified, use a random offset between 0 and 500
  // to allow several contributors to work with the bests humans tasks at the same time
  // while having a low risk of conflicting
  // (only for human tasks as there are not that many work tasks)
  if (offset === 0 && entitiesType === 'human') {
    offset = Math.trunc(Math.random() * 500)
    // Predictable behavior in development environment
    if (window.env === 'dev') offset = 0
  }
  let { tasks } = await requestNewTasks(entitiesType, limit, offset)
  offset += limit
  tasks = tasks.filter(removePreviousTasks(previousTasksIds))
  return updateBacklogAndGetNextTask(tasks, nextTaskGetter)
}

function areTasksInBacklog (backlogName) {
  return backlogs[backlogName].length !== 0
}

const getNextTaskBySuggestionUri = async params => {
  const { lastTask, previousTasksIds } = params
  const suggestionUri = lastTask.suggestionUri

  const { tasks } = await preq.get(app.API.tasks.bySuggestionUris(suggestionUri))
  let suggestionUriTasks = tasks[suggestionUri]
  suggestionUriTasks = suggestionUriTasks
    .filter(removePreviousTasks(previousTasksIds))
    .filter(tasksWithOccurences)
  suggestionUrisFetched.push(suggestionUri)
  if (suggestionUriTasks.length === 0) return getNextTask(params)
  else return updateBacklogAndGetNextTask(suggestionUriTasks, params.backlogName)
}

const requestNewTasks = async (type, limit, offset) => {
  if (type === 'work') {
    return preq.get(app.API.tasks.byEntitiesType({ type, limit, offset }))
  } else {
    return preq.get(app.API.tasks.byScore(limit, offset))
  }
}
const removePreviousTasks = previousTasksIds => task => !previousTasksIds.includes(task._id)

const tasksWithOccurences = task => isNonEmptyArray(task.externalSourcesOccurrences)

const updateBacklogAndGetNextTask = (tasks = [], backlogName) => {
  backlogs[backlogName].push(...tasks)
  return shiftTaskFromBacklog(backlogName)
}

const shiftTaskFromBacklog = backlogName => {
  const backlog = backlogs[backlogName]
  if (backlog.length === 0) return
  return backlog.shift()
}
