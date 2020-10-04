import preq from 'lib/preq'
import Entities from '../collections/entities'
import MergeSuggestions from '../views/editor/merge_suggestions'
import Task from 'modules/tasks/models/task'
import loader from 'modules/general/views/templates/loader.hbs'
const entitiesTypesWithTasks = [
  'human'
]

export default function (params) {
  if (!app.user.hasDataadminAccess) return
  const { region, model, standalone } = params
  $(region.el).html(loader())

  return getMergeSuggestions(model)
  .then(entities => {
    const collection = new Entities(entities)
    return region.show(new MergeSuggestions({ collection, model, standalone }))
  })
};

const getMergeSuggestions = model => getTasksByUri(model)
.then(tasksEntitiesData => {
  const tasksEntitiesUris = _.pluck(tasksEntitiesData, 'uri')
  return getHomonyms(model, tasksEntitiesUris)
  // returning a mix of raw objects and models
  .then(homonymEntities => tasksEntitiesData.concat(homonymEntities))
})

const getTasksByUri = function (model) {
  const type = model.get('type')
  if (!entitiesTypesWithTasks.includes(type)) {
    return Promise.resolve([])
  }

  const uri = model.get('uri')
  const [ action, relation ] = getMergeSuggestionsParams(uri)
  return preq.get(app.API.tasks[action](uri))
  .then(res => {
    const tasks = res.tasks[uri]
    const suggestionsUris = _.pluck(tasks, relation)
    return app.request('get:entities:models', { uris: suggestionsUris })
    .then(addTasksToEntities(uri, tasks, relation))
  })
}

const getMergeSuggestionsParams = function (uri) {
  const [ prefix ] = uri.split(':')
  if (prefix === 'wd') {
    return [ 'bySuggestionUris', 'suspectUri' ]
  } else {
    return [ 'bySuspectUris', 'suggestionUri' ]
  }
}

const addTasksToEntities = (uri, tasks, relation) => function (entities) {
  const tasksIndex = _.indexBy(tasks, relation)

  entities.forEach(entity => {
    if (!entity.tasks) { entity.tasks = {} }
    const task = tasksIndex[entity.get('uri')]
    entity.tasks[uri] = new Task(task)
  })

  entities.sort((a, b) => b.tasks[uri].get('globalScore') - a.tasks[uri].get('globalScore'))

  return entities
}

const getHomonyms = function (model, tasksEntitiesUris) {
  const [ uri, label ] = model.gets('uri', 'label')
  const { pluralizedType } = model
  return preq.get(app.API.search(pluralizedType, label, 100))
  .get('results')
  .then(parseSearchResults(uri, tasksEntitiesUris))
}

const parseSearchResults = (uri, tasksEntitiesUris) => function (searchResults) {
  let uris = _.pluck(searchResults, 'uri')
  const prefix = uri.split(':')[0]
  if (prefix === 'wd') { uris = uris.filter(isntWdUri) }
  // Omit the current entity URI and the entities for which a task was found
  const urisToOmit = [ uri ].concat(tasksEntitiesUris)
  uris = _.without(uris, ...urisToOmit)
  // Search results entities miss their claims, so we need to fetch the full entities
  return app.request('get:entities:models', { uris })
  // Re-filter out uris to omit as a redirection might have brought it back
  .then(entities => entities.filter(entity => {
    return !urisToOmit.includes(entity.get('uri'))
  }))
}

const isntWdUri = uri => uri.split(':')[0] !== 'wd'
