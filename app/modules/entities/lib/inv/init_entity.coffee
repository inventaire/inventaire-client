Tasks = require 'modules/tasks/collections/tasks'

module.exports = ->
  @set 'aliases', {}
  _.extend @, specificMethods

specificMethods =
  fetchMergeSuggestions: ->
    if @mergeSuggestions? then return _.preq.resolve @mergeSuggestions

    uri = @get 'uri'
    _.preq.get app.API.tasks.bySuspectUris(uri)
    .then (res)=>
      @mergeSuggestions = new Tasks(res.tasks[uri])
      @mergeSuggestions.sort()
      return @mergeSuggestions
