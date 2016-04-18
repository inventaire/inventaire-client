# Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.collection.coffee
valueKey = 'value'

module.exports = (options)->
  { collection, remote } = options.source()
  # FilteredCollection don't have an extend method
  # and do weird things when `call`ed with Backbone.Collection.extend
  # so here is a custom extension
  suggestions = new FilteredCollection collection
  _.extend suggestions, suggestionMethods
  suggestions.init remote
  return suggestions

# module.exports = Backbone.Collection.extend
suggestionMethods =
  init: (remote)->
    @index = -1
    @remote = remote
    @on 'find', @fetchNewSuggestions
    @on 'select', @select
    @on 'highlight:next', @highlightNext
    @on 'highlight:previous', @highlightPrevious

  # Get suggestions based on the current input. Either query
  # the api or filter the dataset.
  fetchNewSuggestions: (query)->
    @index = -1
    @filterByText query
    @remote query

  # Select first suggestion unless the suggestion list
  # has been navigated then select at the current index.
  select: ->
    index = if @isStarted() then @index else 0
    @trigger 'selected', @at(index)

  highlightPrevious: ->
    _.log 'highlight:previous'
    unless @isFirst() or not @isStarted()
      @removeHighlight @index
      @index -= 1
      @highlight @index

  highlightNext: ->
    _.log 'highlight:next'
    unless @isLast()
      if @isStarted() then @removeHighlight @index
      @index += 1
      @highlight @index

  isFirst: -> @index is 0
  isLast: -> @index + 1 is @length

  # Check to see if we have navigated through the
  # suggestions list yet.
  isStarted: -> @index isnt -1

  highlight: (index)->
    model = @at index
    model.trigger 'highlight', model
    # (1)
    @trigger 'highlight', model

  removeHighlight: (index)->
    model = @at index
    model.trigger 'highlight:remove', model
    # (1)
    @trigger 'highlight:remove', model

# (1):
# the event needs to be triggered on the filteredCollection too
# as it isn't the model's native collection, thus the event
# isn't automatically triggered

# Check to see if the query matches the suggestion.
matching = (suggestion, query)->
  suggestion = normalizeValue suggestion
  query = normalizeValue query
  return suggestion.indexOf(query) >= 0

normalizeValue = (string='')->
  string
  .toLowerCase()
  .replace /^\s*/g, ''
  .replace /\s{2,}/g, ' '
