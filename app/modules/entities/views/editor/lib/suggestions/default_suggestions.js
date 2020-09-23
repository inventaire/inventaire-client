batchLength = 10
{ prepareSearchResult } = require 'modules/entities/lib/search/entities_uris_results'
getSuggestionsPerProperties = require 'modules/entities/views/editor/lib/get_suggestions_per_properties'

addDefaultSuggestionsUris = ->
  getSuggestionsPerProperties @property, @model
  .then setDefaultSuggestions.bind(@)

setDefaultSuggestions = (uris)->
  unless uris? then return

  @_showingDefaultSuggestions = true
  @_remainingDefaultSuggestionsUris = uris
  @_defaultSuggestions = []

  addNextDefaultSuggestionsBatch.call @
  .then =>
    if @_showingDefaultSuggestions then showDefaultSuggestions.call @

showDefaultSuggestions = ->
  if @_defaultSuggestions? and @_defaultSuggestions.length > 0
    @suggestions.reset @_defaultSuggestions
    @showDropdown()
  else
    @hideDropdown()

addNextDefaultSuggestionsBatch = ->
  uris = @_remainingDefaultSuggestionsUris
  if uris.length is 0 then return Promise.resolve()

  nextBatch = uris.slice 0, batchLength
  @_remainingDefaultSuggestionsUris = uris.slice batchLength

  app.request 'get:entities:models', { uris: nextBatch }
  .map prepareSearchResult
  .then (results)=>
    @_defaultSuggestions.push results...
    @suggestions.add results

module.exports = { addDefaultSuggestionsUris, addNextDefaultSuggestionsBatch, showDefaultSuggestions }
