# A set of functions to display a list of suggestions and the the view be informed of
# the selected suggestion via onAutoCompleteSelect and onAutoCompleteUnselect hooks

# Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.behavior.coffee

getActionKey = require 'lib/get_action_key'
Suggestions = require 'modules/entities/collections/suggestions'
AutocompleteSuggestions = require '../autocomplete_suggestions'
properties = require 'modules/entities/lib/properties'
typeSearch = require 'modules/entities/lib/search/type_search'
forms_ = require 'modules/general/lib/forms'
batchLength = 10
types_ = require 'lib/types'
{ prepareSearchResult } = require 'modules/entities/lib/search/entities_uris_results'

module.exports =
  onRender: ->
    unless @suggestions? then initializeAutocomplete.call @
    @suggestionsRegion.show new AutocompleteSuggestions { collection: @suggestions }

  setDefaultSuggestions: (uris)->
    unless uris? then return
    @_showingDefaultSuggestions = true
    @_remainingDefaultSuggestionsUris = uris
    @_defaultSuggestions = []

    addNextDefaultSuggestionsBatch.call @
    .then =>
      if @_showingDefaultSuggestions then showDefaultSuggestions.call @

  onKeyDown: (e)->
    key = getActionKey e
    # only addressing 'tab' as it isn't caught by the keyup event
    if key is 'tab'
      # In the case the dropdown was shown and a value was selected
      # @fillQuery will have been triggered, the input filled
      # and the selected suggestion kept at end: we can let the event
      # propagate to move to the next input
      @hideDropdown()

  onKeyUp: (e)->
    e.preventDefault()
    e.stopPropagation()

    value = @ui.input.val()

    actionKey = getActionKey e

    if actionKey?
      keyAction.call @, actionKey, e
    else if value.length is 0
      showDefaultSuggestions.call @
      @_showingDefaultSuggestions = true
    else if value isnt @_lastValue
      @showDropdown()
      @lazySearch value
      @_showingDefaultSuggestions = false

    @_lastValue = value

  showDropdown: ->
    @suggestionsRegion.$el.show()

  hideDropdown: ->
    @suggestionsRegion.$el.hide()
    @ui.input.focus()

initializeAutocomplete = ->
  property = @options.model.get 'property'
  { @searchType } = properties[property]
  @suggestions = new Suggestions [], { property }
  @lazySearch = _.debounce search.bind(@), 400

  @listenTo @suggestions, 'selected:value', completeQuery.bind(@)
  @listenTo @suggestions, 'highlight', fillQuery.bind(@)
  @listenTo @suggestions, 'error', showAlertBox.bind(@)
  @listenTo @suggestions, 'load:more', loadMore.bind(@)

showDefaultSuggestions = ->
  if @_defaultSuggestions? and @_defaultSuggestions.length > 0
    @suggestions.reset @_defaultSuggestions
    @showDropdown()
  else
    @hideDropdown()

# Complete the query using the selected suggestion.
completeQuery = (suggestion)->
  fillQuery.call @, suggestion
  @hideDropdown()

search = (input)->
  showLoadingSpinner.call @
  # remove the value passed to the view as the input changed
  removeCurrentViewValue.call @

  input = input.trim().replace /\s{2,}/g, ' '
  if input is @lastInput then return Promise.resolve()

  @suggestions.index = -1
  @lastInput = input
  @_searchOffset = 0

  _search.call @, input
  .then (results)=>
    @_lastResultsLength = results.length
    if results? and results.length is 0
      @suggestionsRegion.currentView.$el.addClass 'no-results'
    else
      @suggestionsRegion.currentView.$el.removeClass 'no-results'
    @suggestions.reset results
    stopLoadingSpinner.call @
  .catch forms_.catchAlert.bind(null, @)

_search = (input)->
  typeSearch @searchType, input, batchLength, @_searchOffset
  .then (results)=>
    # Ignore the results if the input changed
    if input isnt @lastInput then return
    return results

loadMore = ->
  if @_showingDefaultSuggestions then addNextDefaultSuggestionsBatch.call @
  else loadMoreFromSearch.call @

loadMoreFromSearch = ->
  # Do not try to fetch more results if the last batch was incomplete
  if @_lastResultsLength < batchLength then return stopLoadingSpinner.call @

  showLoadingSpinner.call @, false
  @_searchOffset += batchLength
  _search.call @, @lastInput
  .then (results)=>
    currentResultsUri = @suggestions.map (model)-> model.get('uri')
    newResults = results.filter (result)-> result.uri not in currentResultsUri
    @_lastResultsLength = newResults.length
    if newResults.length > 0 then @suggestions.add newResults
    stopLoadingSpinner.call @, false
  .catch forms_.catchAlert.bind(null, @)

showLoadingSpinner = (toggleResults = true)->
  @suggestionsRegion.currentView.showLoadingSpinner()
  if toggleResults then @$el.find('.results').hide()

stopLoadingSpinner = (toggleResults = true)->
  @suggestionsRegion.currentView.stopLoadingSpinner()
  if toggleResults then @$el.find('.results').show()

removeCurrentViewValue = ->
  @onAutoCompleteUnselect()

# Complete the query using the highlighted or the clicked suggestion.
fillQuery = (suggestion)->
  @ui.input
  .val suggestion.get('label')

  @onAutoCompleteSelect suggestion

showAlertBox = (err)->
  @$el.trigger 'alert', { message: err.message }

# Check to see if the cursor is at the end of the query string.
isSelectionEnd = (e)->
  { value, selectionEnd } = e.target
  return value.length is selectionEnd

keyAction = (actionKey, e)->
  # actions happening in any case
  switch actionKey
    when 'esc' then return @hideDropdown()

  # actions conditional to suggestions state
  unless @suggestions.isEmpty()
    switch actionKey
      when 'enter' then @suggestions.trigger 'select:from:key'
      when 'down'
        @showDropdown()
        @suggestions.trigger 'highlight:next'
      when 'up'
        @showDropdown()
        @suggestions.trigger 'highlight:previous'
      # when 'home' then @suggestions.trigger 'highlight:first'
      # when 'end' then @suggestions.trigger 'highlight:last'

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
