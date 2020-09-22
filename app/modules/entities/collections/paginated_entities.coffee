Entities = require './entities'

module.exports = Entities.extend
  initialize: (models, options = {})->
    { uris } = options
    unless uris? then throw new Error 'expected uris'
    # Clone the array as it will be mutated
    @allUris = uris.slice(0)
    # At the begining, all URIs are unfetched URIs
    @remainingUris = @allUris
    @totalLength = uris.length
    @fetchedUris = []
    { @refresh, @defaultType, @parentContext } = options
    @typesAllowlist ?= options.typesAllowlist

  resetFromUris: (uris)->
    @remainingUris = uris
    @reset()
    @fetchMore()

  fetchMore: (amount = 10)->
    urisToFetch = @remainingUris.splice(0, amount)
    fetchedUrisBefore = @fetchedUris
    @fetchedUris = @fetchedUris.concat(urisToFetch)

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
    if not @typesAllowlist? or entity.type in @typesAllowlist then return true
    else
      app.execute 'report:entity:type:issue',
        model: entity
        expectedType: @typesAllowlist
        context:
          module: module.id
          allUris: JSON.stringify @allUris
          parentContext: if @parentContext? then JSON.stringify @parentContext
      return false
