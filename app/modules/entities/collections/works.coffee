module.exports = Backbone.Collection.extend
  initialize: (models, options)->
    @remainingUris = options.uris
    unless @remainingUris? then throw new Error 'expected uris'
    @totalLength = options.uris.length
    @fetchedUris = []

  fetchMore: (amount)->
    urisToFetch = _.difference @remainingUris[0...amount], @fetchedUris
    fetchedUrisBefore = @fetchedUris
    @fetchedUris = @fetchedUris.concat urisToFetch
    @remainingUris = @remainingUris[amount..-1]

    rollback = =>
      @remainingUris = urisToFetch.concat @remainingUris
      @fetchedUris = fetchedUrisBefore

    app.request 'get:entities:models:from:uris', urisToFetch
    .then @add.bind(@)
    .catch rollback

  firstFetch: (amount)->
    unless @_firstFetchDone
      @_firstFetchDone = true
      @fetchMore amount

  more: -> @remainingUris.length
