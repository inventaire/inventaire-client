mergeEntities = require 'modules/entities/views/editor/lib/merge_entities'

module.exports = Backbone.Model.extend
  initialize: ->
    unless @get('type')? then throw new Error('invalid task')

    suspectUri = @get('suspectUri')
    suggestionUri = @get 'suggestionUri'

    @waitForData = Promise.all [
      @grabAuthor suspectUri, 'suspect'
      @grabAuthor suggestionUri, 'suggestion'
    ]

    @set 'pathname', "/tasks/#{@id}"

  grabAuthor: (uri, name)->
    @reqGrab 'get:entity:model', uri, name
    .then (model)-> model.initAuthorWorks()

  updateMetadata: ->
    type = @get('type') or 'task'
    names = @suspect?.get('label') + ' / ' + @suggestion?.get('label')
    return {
      title: "[#{_.i18n(type)}] #{names}"
    }

  dismiss: ->
    _.preq.put app.API.tasks.update,
      id: @id
      attribute: 'state'
      value: 'dismissed'

  merge: ->
    mergeEntities @get('suspectUri'), @get('suggestionUri')
