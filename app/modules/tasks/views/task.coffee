mergeEntities = require 'modules/entities/views/editor/lib/merge_entities'

module.exports = Marionette.ItemView.extend
  template: require './templates/task'
  initialize: -> @lazyRender = _.LazyRender @

  onShow: -> @listenTo @model, 'grab', @lazyRender

  serializeData: ->
    _.extend @model.toJSON(),
      suspect: @model.suspect?.toJSON()
      suggestion: @model.suggestion?.toJSON()

  events:
    'click .merge': 'merge'

  merge: ->
    mergeEntities @suspectUri, @suggestionUri
    .then updateTask

  updateTask: ->
    taskId = @task._id
    _.preq.put app.API.tasks.base