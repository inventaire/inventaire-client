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

    rollback = (err)=>
      @remainingUris = urisToFetch.concat @remainingUris
      @fetchedUris = fetchedUrisBefore
      _.error err, 'failed to fetch more works: rollback'

    app.request 'get:entities:models',
      uris: urisToFetch,
      refresh: @refresh,
      defaultType: @defaultType
    .then filterOutInvalidWorks
    .then @add.bind(@)
    .catch rollback

  fetchAll: -> @fetchMore @remainingUris.length

  firstFetch: (amount)->
    unless @_firstFetchDone
      @_firstFetchDone = true
      @fetchMore amount

  more: -> @remainingUris.length

filterOutInvalidWorks = (works)-> works.filter filterOutAndRerportInvalidWork

filterOutAndRerportInvalidWork = (work)->
  if work.type is 'work' or work.type is 'serie'
    return true
  else
    app.execute 'report:entity:type:issue', { model: work, expectedType: 'work' }
    return false
