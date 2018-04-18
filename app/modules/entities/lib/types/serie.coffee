Works = require '../../collections/works'
commonsSerieWork = require './commons_serie_work'

module.exports = ->
  # Main property by which sub-entities are linked to this one
  @childrenClaimProperty = 'wdt:P179'

  _.extend @, specificMethods

typesString =
  'wd:Q277759': 'book series'
  'wd:Q14406742': 'comic book series'
  'wd:Q21198342': 'manga series'

specificMethods = _.extend {}, commonsSerieWork(typesString, 'series'),
  initSerieParts: (refresh)->
    refresh = @getRefresh refresh
    if not refresh and @waitForParts? then return @waitForParts

    uri = @get 'uri'

    @waitForParts = _.preq.get app.API.entities.serieParts(uri, refresh)
    .then @initPartsCollections.bind(@, refresh)
    .then @importDataFromParts.bind(@)

  initPartsCollections: (refresh, res)->
    @parts = new Works null,
      uris: res.parts.map getUri
      defaultType: 'work'
      refresh: refresh

  importDataFromParts: ->
    firstPartWithPublicationDate = @parts.find getPublicationDate
    if firstPartWithPublicationDate?
      @set 'publicationStart', getPublicationDate(firstPartWithPublicationDate)

  # Placeholder for cases when a series was formerly identified as a work
  # and got editions or items linking to it, assuming it is a work
  getItemsByCategories: ->
    app.execute 'report:entity:type:issue', { model: @, expectedType: 'work' }
    return Promise.resolve { personal: [], network: [], public: [] }

getUri = _.property 'uri'
getPublicationDate = (model)-> model.get 'claims.wdt:P577.0'
