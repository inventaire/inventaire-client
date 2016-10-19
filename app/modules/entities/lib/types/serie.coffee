Works = require '../../collections/works'

module.exports = ->
  # Main property by which sub-entities are linked to this one
  @childrenClaimProperty = 'wdt:P361'

  _.extend @, specificMethods


specificMethods =
  initSerieParts: (refresh)->
    _.log refresh, 'refresh initSerieParts??'
    if not refresh and @waitForParts? then return @waitForParts

    uri = @get 'uri'

    @waitForParts = _.preq.get app.API.entities.serieParts(uri, refresh)
    .then _.Log("serie parts - #{uri}")
    .then @initPartsCollections.bind(@, refresh)
    .then @importDataFromParts.bind(@)

  initPartsCollections: (refresh, res)->
    { parts } = res
    parts = res.parts.map getUri
    # Emit the event associated event
    @set 'parts', parts
    @parts = new Works null, { uris: parts, refresh }

  importDataFromParts: ->
    firstPartWithPublicationDate = @parts.find getPublicationDate
    if firstPartWithPublicationDate?
      @set 'publicationStart', getPublicationDate(firstPartWithPublicationDate)

getUri = _.property 'uri'
getPublicationDate = (model)-> model.get 'claims.wdt:P577.0'
