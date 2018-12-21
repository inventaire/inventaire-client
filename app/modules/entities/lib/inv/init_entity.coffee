Tasks = require 'modules/tasks/collections/tasks'

module.exports = ->
  @set 'aliases', {}
  _.extend @, specificMethods

specificMethods =
  fetchMergeSuggestions: ->
    if @mergeSuggestionsPromise? then return @mergeSuggestionsPromise

    uri = @get 'uri'

    @mergeSuggestionsPromise = _.preq.get app.API.tasks.bySuspectUris(uri)
      .then (res)=>
        tasks = res.tasks[uri]
        @mergeSuggestions = new Tasks(tasks)
        @mergeSuggestions.sort()
        return @mergeSuggestions
