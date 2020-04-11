Entities = require '../collections/entities'
MergeSuggestions = require '../views/editor/merge_suggestions'
Task = require 'modules/tasks/models/task'
loader = require 'modules/general/views/templates/loader'
entitiesTypesWithTasks = [
  'human'
]

module.exports = (params)->
  unless app.user.isAdmin then return
  { region, model, standalone } = params
  $(region.el).html loader()

  getMergeSuggestions model
  .then (entities)->
    collection = new Entities entities
    region.show new MergeSuggestions { collection, model, standalone }

getMergeSuggestions = (model)->
  getTasksByUri model
  .then (tasksEntitiesData)->
    tasksEntitiesUris = _.pluck tasksEntitiesData, 'uri'
    getHomonyms model, tasksEntitiesUris
    # returning a mix of raw objects and models
    .then (homonymEntities)-> tasksEntitiesData.concat(homonymEntities)

getTasksByUri = (model)->
  unless model.get('type') in entitiesTypesWithTasks
    return Promise.resolve []

  uri = model.get 'uri'
  [ action, relation ] = getMergeSuggestionsParams uri
  _.preq.get app.API.tasks[action](uri)
  .then (res)->
    tasks = res.tasks[uri]
    suggestionsUris = _.pluck tasks, relation
    app.request 'get:entities:models', { uris: suggestionsUris }
    .then addTasksToEntities(uri, tasks, relation)

getMergeSuggestionsParams = (uri)->
  [ prefix, id ] = uri.split ':'
  if prefix is 'wd' then [ 'bySuggestionUris', 'suspectUri' ]
  else [ 'bySuspectUris', 'suggestionUri' ]

addTasksToEntities = (uri, tasks, relation)-> (entities)->
  tasksIndex = _.indexBy tasks, relation

  entities.forEach (entity)->
    entity.tasks or= {}
    task = tasksIndex[entity.get('uri')]
    entity.tasks[uri] = new Task task

  entities.sort (a, b)-> b.tasks[uri].get('globalScore') - a.tasks[uri].get('globalScore')

  return entities

getHomonyms = (model, tasksEntitiesUris)->
  [ uri, label ] = model.gets 'uri', 'label'
  { pluralizedType } = model
  _.preq.get app.API.search(pluralizedType, label, 100)
  .get 'results'
  .then parseSearchResults(uri, tasksEntitiesUris)

parseSearchResults = (uri, tasksEntitiesUris)-> (searchResults)->
  uris = _.pluck searchResults, 'uri'
  prefix = uri.split(':')[0]
  if prefix is 'wd' then uris = uris.filter isntWdUri
  # Omit the current entity URI and the entities for which a task was found
  urisToOmit = [ uri ].concat tasksEntitiesUris
  uris = _.without uris, urisToOmit...
  # Search results entities miss their claims, so we need to fetch the full entities
  return app.request 'get:entities:models', { uris }
  # Re-filter out uris to omit as a redirection might have brought it back
  .then (entities)-> entities.filter (entity)-> entity.get('uri') not in urisToOmit

isntWdUri = (uri)-> uri.split(':')[0] isnt 'wd'
