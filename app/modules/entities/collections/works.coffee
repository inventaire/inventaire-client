module.exports = Backbone.Collection.extend
  initialize: (models, options)->
    # At the begining, all URIs are unfetched URIs
    @remainingUris = @allUris = options.uris
    unless @remainingUris? then throw new Error 'expected uris'
    @totalLength = options.uris.length
    @fetchedUris = []
    { @refresh, @defaultType } = options

  fetchMore: (amount)->
    urisToFetch = _.difference @remainingUris[0...amount], @fetchedUris
    fetchedUrisBefore = @fetchedUris
    @fetchedUris = @fetchedUris.concat urisToFetch
    @remainingUris = @remainingUris[amount..-1]

    rollback = =>
      @remainingUris = urisToFetch.concat @remainingUris
      @fetchedUris = fetchedUrisBefore

    app.request 'get:entities:models',
      uris: urisToFetch,
      refresh: @refresh,
      defaultType: @defaultType
    .then @add.bind(@)
    .catch rollback

  fetchAll: -> @fetchMore @remainingUris.length

  firstFetch: (amount)->
    unless @_firstFetchDone
      @_firstFetchDone = true
      @fetchMore amount

  more: -> @remainingUris.length
