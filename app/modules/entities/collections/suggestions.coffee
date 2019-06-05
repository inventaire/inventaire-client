# Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.collection.coffee

module.exports = Backbone.Collection.extend
  initialize: (data, options)->
    { property } = options
    @lastInput = null

    @index = -1

    @on 'highlight:next', @highlightNext
    @on 'highlight:previous', @highlightPrevious
    @on 'highlight:first', @highlightFirst
    @on 'highlight:last', @highlightLast
    @on 'select:from:key', @selectFromKey
    @on 'select:from:click', @selectFromClick

  model: require 'modules/entities/models/search_result'

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
