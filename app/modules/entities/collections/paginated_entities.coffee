Entities = require './entities'

module.exports = Entities.extend
  initialize: (models, options = {})->
    # At the begining, all URIs are unfetched URIs
    @remainingUris = @allUris = options.uris
    unless @remainingUris? then throw new Error 'expected uris'
    @totalLength = options.uris.length
    @fetchedUris = []
    { @refresh, @defaultType } = options
    @typesWhitelist ?= options.typesWhitelist

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
    .filter @filterOutUndesiredTypes.bind(@)
    .then @add.bind(@)
    .catch rollback

  fetchAll: -> @fetchMore @remainingUris.length

  firstFetch: (amount)->
    unless @_firstFetchDone
      @_firstFetchDone = true
      @fetchMore amount

  more: -> @remainingUris.length

  filterOutUndesiredTypes: (entity)->
    if not @typesWhitelist? or entity.type in @typesWhitelist then return true
    else
      data = { model: entity, expectedType: @typesWhitelist, context: module.id }
      app.execute 'report:entity:type:issue', data
      return false
