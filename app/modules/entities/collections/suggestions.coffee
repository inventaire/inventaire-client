# Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.collection.coffee

typeSearch = require 'modules/entities/lib/search/type_search'
properties = require 'modules/entities/lib/properties'

module.exports = Backbone.Collection.extend
  initialize: (data, options)->
    { property } = options
    { @searchType } = properties[property]
    @lastInput = null

    @index = -1

    # Using the filtered collection as the behavior event bus
    # but never the original collection as it is shared between all views
    @on 'find', @fetchNewSuggestions
    @on 'highlight:next', @highlightNext
    @on 'highlight:previous', @highlightPrevious
    @on 'highlight:first', @highlightFirst
    @on 'highlight:last', @highlightLast
    @on 'select:from:key', @selectFromKey
    @on 'select:from:click', @selectFromClick

  model: require 'modules/entities/models/search_result'

  # Get suggestions based on the current input
  fetchNewSuggestions: (input)->
    input = input.trim().replace /\s{2,}/g, ' '
    if input is @lastInput then return Promise.resolve()

    @index = -1
    @lastInput = input

    typeSearch @searchType, input
    .then (results)=>
      # Ignore the results if the input changed
      if input isnt @lastInput then return
      # Reset the collection so that previous text search or URI results
      # don't appear in the suggestions
      @reset results
    .catch @trigger.bind(@, 'error')

  # Select first suggestion unless the suggestion list
  # has been navigated then select at the current index.
  selectFromKey: ->
    index = if @isStarted() then @index else 0
    @trigger 'selected:value', @at(index)

  selectFromClick: (model)->
    @index = @models.indexOf model
    @trigger 'selected:value', model

  highlightPrevious: -> unless @isFirst() then @highlightAt @index - 1
  highlightNext: -> unless @isLast() then @highlightAt @index + 1
  highlightFirst: -> @highlightAt 0
  highlightLast: -> @highlightAt @length - 1
  highlightAt: (index)->
    if @index is index then return

    if @isStarted() then @removeHighlight @index
    @index = index
    @highlight index

  isFirst: -> @index is 0
  isLast: -> @index is @length - 1

  # Check to see if we have navigated through the
  # suggestions list yet.
  isStarted: -> @index isnt -1

  highlight: (index)-> @highlightEvent 'highlight', index
  removeHighlight: (index)-> @highlightEvent 'highlight:remove', index
  highlightEvent: (eventName, index)->
    model = @at index
    # Known case: the collection just got reset
    unless model? then return
    model.trigger eventName, model
    # events required by modules/entities/views/editor/lib/autocomplete.coffee
    @trigger eventName, model
