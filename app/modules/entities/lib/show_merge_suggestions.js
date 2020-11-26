import preq from 'lib/preq'
import Entities from '../collections/entities'
import loader from 'modules/general/views/templates/loader.hbs'

const entitiesTypesWithTasks = [
  'human'
]

export default async params => {
  if (!app.user.hasDataadminAccess) return
  const { region, model, standalone } = params
  $(region.el).html(loader())

  const [ entities, { default: MergeSuggestions } ] = await Promise.all([
    getMergeSuggestions(model),
    import('../views/editor/merge_suggestions')
  ])
  const collection = new Entities(entities)
  region.show(new MergeSuggestions({ collection, model, standalone }))
}

const getMergeSuggestions = async model => {
  const tasksEntitiesData = await getTasksByUri(model)
  const tasksEntitiesUris = _.pluck(tasksEntitiesData, 'uri')
  const homonymEntities = await getHomonyms(model, tasksEntitiesUris)
  // returning a mix of raw objects and models
  return tasksEntitiesData.concat(homonymEntities)
}

const getTasksByUri = async model => {
  const type = model.get('type')
  if (!entitiesTypesWithTasks.includes(type)) return []

  const uri = model.get('uri')
  const [ action, relation ] = getMergeSuggestionsParams(uri)
  const res = await preq.get(app.API.tasks[action](uri))
  const tasks = res.tasks[uri]
  const suggestionsUris = _.pluck(tasks, relation)
  let entities = await app.request('get:entities:models', { uris: suggestionsUris })
  // Filter-out redirected entities
  // Known case: we got an obsolete task
  entities = entities.filter(entity => suggestionsUris.includes(entity.get('uri')))
  return addTasksToEntities(uri, tasks, relation, entities)
}

const getMergeSuggestionsParams = uri => {
  const [ prefix ] = uri.split(':')
  if (prefix === 'wd') {
    return [ 'bySuggestionUris', 'suspectUri' ]
  } else {
    return [ 'bySuspectUris', 'suggestionUri' ]
  }
}

const addTasksToEntities = async (uri, tasks, relation, entities) => {
  const { default: Task } = await import('modules/tasks/models/task')

  const tasksIndex = _.indexBy(tasks, relation)

  entities.forEach(entity => {
    if (!entity.tasks) entity.tasks = {}
    const task = tasksIndex[entity.get('uri')]
    entity.tasks[uri] = new Task(task)
  })

  entities.sort((a, b) => b.tasks[uri].get('globalScore') - a.tasks[uri].get('globalScore'))

  return entities
}

const getHomonyms = async (model, tasksEntitiesUris) => {
  const [ uri, label ] = model.gets('uri', 'label')
  const { type } = model
  const pluralizedType = type + 's'
  const { results } = await preq.get(app.API.search(pluralizedType, label, 100))
  return parseSearchResults(uri, tasksEntitiesUris, results)
}

const parseSearchResults = async (uri, tasksEntitiesUris, searchResults) => {
  let uris = _.pluck(searchResults, 'uri')
  const prefix = uri.split(':')[0]
  if (prefix === 'wd') uris = uris.filter(isntWdUri)
  // Omit the current entity URI and the entities for which a task was found
  const urisToOmit = [ uri ].concat(tasksEntitiesUris)
  uris = _.without(uris, ...urisToOmit)
  // Search results entities miss their claims, so we need to fetch the full entities
  const entities = await app.request('get:entities:models', { uris })
  // Re-filter out uris to omit as a redirection might have brought it back
  return entities.filter(entity => !urisToOmit.includes(entity.get('uri')))
}

const isntWdUri = uri => uri.split(':')[0] !== 'wd'
