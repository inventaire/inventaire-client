module.exports = Backbone.Model.extend
  initialize: ->
    suspectUri = @get 'suspectUri'
    suggestionUri = @get 'suggestionUri'
    @reqGrab 'get:entity:model', suspectUri, 'suspect'
    @reqGrab 'get:entity:model', suggestionUri, 'suggestion'
