# Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.collection.coffee

module.exports = Backbone.Collection.extend
  initialize: (models, @options)->
    @setDataset @options.data

    @on 'find', @fetchNewSuggestions
    @on 'select', @select
    @on 'highlight:next', @highlightNext
    @on 'highlight:previous', @highlightPrevious
    @on 'clear', @reset

  # Save models passed into the constructor seperately to avoid
  # rendering the entire dataset.
  setDataset: (dataset)->
    @dataset = @parse dataset, no

  # Parse API response
  parse: (suggestions, limit)->
    { parseKey, valueKey, values } = @options

    if parseKey
      suggestions = _.get suggestions, parseKey

    if limit
      suggestions = _.take suggestions, values.limit

    suggestions.map (suggestion)->
      _.extend suggestion, { value: _.get(suggestion, valueKey) }

  # Get query parameters.
  getParams: (query)->
    data = {}
    { keys, values } = @options

    data[keys.query] = query

    for k, v of keys
      data[v] ?= values[k]

    { data }

  # Get suggestions based on the current input. Either query
  # the api or filter the dataset.
  fetchNewSuggestions: (query)->
    { type, remote } = @options
    switch type
      when 'remote'
        @fetch _.extend({ url: remote, reset: yes }, @getParams(query))
      when 'dataset'
        @filterDataSet query
      else
        throw new Error 'Unkown type passed'

  filterDataSet: (query)->
    matches = []
    @index = -1

    for suggestion in @dataset
      if matches.length >= @options.values.limit then return false

      if matching(suggestion.value, query) then matches.push suggestion

    @set matches

  # Select first suggestion unless the suggestion list
  # has been navigated then select at the current index.
  select: ->
    index = if @isStarted() then @index else 0
    @trigger 'selected', @at(index)

  highlightPrevious: ->
    unless @isFirst() or not @isStarted()
      @removeHighlight @index
      @index -= 1
      @highlight @index

  highlightNext: ->
    unless @isLast()
      if @isStarted() then @removeHighlight @index
      @highlight @index = @index + 1

  isFirst: -> @index is 0
  isLast: -> @index + 1 is @length

  # Check to see if we have navigated through the
  # suggestions list yet.
  isStarted: -> @index isnt -1

  highlight: (index)->
    model = @at index
    model.trigger 'highlight', model

  removeHighlight: (index)->
    model = @at index
    model.trigger 'highlight:remove', model

  reset: ->
    @index = -1
    Backbone.Collection::reset.apply @, arguments

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
