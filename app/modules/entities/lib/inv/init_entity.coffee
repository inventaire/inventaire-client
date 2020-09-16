Tasks = require 'modules/tasks/collections/tasks'

module.exports = (attrs)->
  { _id } = attrs

  @set
    aliases: {}
    isInvEntity: true
    # Always setting the invUri as long as some inv entities
    # use an alternative uri format (namely isbn: uris)
    invUri: "inv:#{_id}"

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
