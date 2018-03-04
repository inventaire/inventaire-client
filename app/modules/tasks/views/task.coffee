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
    'click .dismiss': 'dismiss'

  merge: ->
    mergeEntities @model.get('suggestionUri'), @model.get('suspectUri')
    .then => @model.collection.remove(@model)

  dismiss: ->
    _.inspect @model, 'model'
    _.preq.put app.API.tasks.update,
      id: @model.id
      attribute: 'state'
      value: 'dismissed'
    .then => @model.collection.remove(@model)
