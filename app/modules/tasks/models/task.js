mergeEntities = require 'modules/entities/views/editor/lib/merge_entities'
error_ = require 'lib/error'

module.exports = Backbone.Model.extend
  initialize: (attrs)->
    unless @get('type')? then throw error_.new 'invalid task', 500, attrs

    @calculateGlobalScore()

    @set 'pathname', "/tasks/#{@id}"

  serializeData: ->
    _.extend @toJSON(),
      suspect: @suspect?.toJSON()
      suggestion: @suggestion?.toJSON()
      sources: @getSources()
      sourcesCount: @get('externalSourcesOccurrences').length

  grabAuthor: (name)->
    uri = @get "#{name}Uri"
    @reqGrab 'get:entity:model', uri, name
    .then (model)=>
      resolvedUri = model.get 'uri'
      if resolvedUri isnt uri
        context = { task: @id, oldUri: uri, newUri: resolvedUri }
        throw error_.new "#{name} uri is obsolete", 500, context

      model.initAuthorWorks()

  grabSuspect: -> @grabAuthor 'suspect'

  grabSuggestion: -> @grabAuthor 'suggestion'

  getOtherSuggestions: ->
    @suspect.fetchMergeSuggestions()

  updateMetadata: ->
    type = @get('type') or 'task'
    names = @suspect?.get('label') + ' / ' + @suggestion?.get('label')
    title = "[#{_.i18n(type)}] #{names}"
    return { title }

  dismiss: ->
    _.preq.put app.API.tasks.update,
      id: @id
      attribute: 'state'
      value: 'dismissed'

  merge: ->
    mergeEntities @get('suspectUri'), @get('suggestionUri')

  calculateGlobalScore: ->
    score = 0
    externalSourcesOccurrencesCount = @get('externalSourcesOccurrences').length
    score += 80 * externalSourcesOccurrencesCount
    score += @get('lexicalScore')
    score += @get('relationScore') * 10
    @set 'globalScore', Math.trunc(score * 100) / 100

  getSources: ->
    @get 'externalSourcesOccurrences'
    .map (source)->
      { url, uri, matchedTitles } = source
      sourceTitle = 'Matched titles: ' + matchedTitles.join(', ')
      if url then return { url, sourceTitle }
      if uri then return { uri, sourceTitle }
