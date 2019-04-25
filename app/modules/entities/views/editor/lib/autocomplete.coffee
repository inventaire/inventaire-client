# A set of functions to display a list of suggestions and the the view be informed of
# the selected suggestion via onAutoCompleteSelect and onAutoCompleteUnselect hooks

# Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.behavior.coffee

getActionKey = require 'lib/get_action_key'
Suggestions = require 'modules/entities/collections/suggestions'
AutocompleteSuggestions = require '../autocomplete_suggestions'

module.exports =
  initialize: ->
    property = @options.model.get 'property'
    # TODO: init @suggestions only if needed
    @suggestions = new Suggestions [], { property }
    @lazyUpdateQuery = _.debounce updateQuery.bind(@), 400

    @listenTo @suggestions, 'selected:value', completeQuery.bind(@)
    @listenTo @suggestions, 'highlight', fillQuery.bind(@)
    @listenTo @suggestions, 'error', showAlertBox.bind(@)

  onRender: ->
    @suggestionsRegion.show new AutocompleteSuggestions { collection: @suggestions }

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
    if value.length is 0
      @hideDropdown()
    else
      actionKey = getActionKey e

      if actionKey?
        keyAction.call @, actionKey, e
      else
        showDropdown.call @
        @lazyUpdateQuery value

  hideDropdown: ->
    @suggestionsRegion.$el.hide()
    @ui.input.focus()

# Complete the query using the selected suggestion.
completeQuery = (suggestion)->
  fillQuery.call @, suggestion
  @hideDropdown()

# Update suggestions list, never directly call this use @lazyUpdateQuery
# which is a debounced alias.
updateQuery = (query)->
  # remove the value passed to the view as the input changed
  removeCurrentViewValue.call @
  @suggestions.trigger 'find', query

removeCurrentViewValue = ->
  @onAutoCompleteUnselect()
  @_suggestionSelected = false

# Complete the query using the highlighted or the clicked suggestion.
fillQuery = (suggestion)->
  @ui.input
  .val suggestion.get('label')

  @onAutoCompleteSelect suggestion
  @_suggestionSelected = true

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
      when 'down' then @suggestions.trigger 'highlight:next'
      when 'up' then @suggestions.trigger 'highlight:previous'
      # when 'home' then @suggestions.trigger 'highlight:first'
      # when 'end' then @suggestions.trigger 'highlight:last'

showDropdown = ->
  @suggestionsRegion.$el.show()
