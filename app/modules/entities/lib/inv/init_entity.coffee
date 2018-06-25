Tasks = require 'modules/tasks/collections/tasks'

module.exports = ->
  @set 'aliases', {}
  _.extend @, specificMethods

specificMethods =
  fetchMergeSuggestions: ->
    if @mergeSuggestions? then return _.preq.resolve @mergeSuggestions

    _.preq.get app.API.tasks.bySuspectUri(@get('uri'))
    .then (res)=>
      @mergeSuggestions = new Tasks(res.tasks)
      @mergeSuggestions.sort()
      return @mergeSuggestions
