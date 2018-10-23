Entities = require '../collections/entities'
MergeSuggestions = require '../views/editor/merge_suggestions'
Task = require 'modules/tasks/models/task'

module.exports = (params)->
  { region, model } = params
  { pluralizedType } = model
  uri = model.get 'uri'
  getMergeSuggestions uri
  .then (entities)->
    if entities.length is 0 then return
    collection = new Entities entities
    region.show new MergeSuggestions { collection, toEntity: model }

getMergeSuggestions = (uri)->
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
