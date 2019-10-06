PaginatedWorks = require '../../collections/paginated_works'
commonsSerieWork = require './commons_serie_work'

module.exports = ->
  # Main property by which sub-entities are linked to this one
  @childrenClaimProperty = 'wdt:P179'

  _.extend @, specificMethods

specificMethods = _.extend {}, commonsSerieWork,
  fetchPartsData: (options = {})->
    { refresh } = options
    if not refresh and @waitForPartsData? then return @waitForPartsData

    uri = @get 'uri'

    @waitForPartsData = _.preq.get app.API.entities.serieParts(uri, refresh)
      .then (res)=> @partsData = res.parts

  initSerieParts: (options)->
    { refresh, fetchAll } = options
    refresh = @getRefresh refresh
    if not refresh and @waitForParts? then return @waitForParts

    @fetchPartsData { refresh }
    .then initPartsCollections.bind(@, refresh, fetchAll)
    .then importDataFromParts.bind(@)

  # Placeholder for cases when a series was formerly identified as a work
  # and got editions or items linking to it, assuming it is a work
  getItemsByCategories: ->
    app.execute 'report:entity:type:issue',
      model: @
      expectedType: 'work'
      context: { module: module.id }
    return Promise.resolve { personal: [], network: [], public: [] }

  getAllAuthorsUris: ->
    allAuthorsUris = getAuthors(@).concat @parts.map(getAuthors)...
    return _.uniq _.compact(allAuthorsUris)

initPartsCollections = (refresh, fetchAll, partsData)->
  @parts = new PaginatedWorks null,
    uris: partsData.map getUri
    defaultType: 'work'
    refresh: refresh
    parentContext:
      entityType: 'serie'
      entityUri: @get 'uri'

  if fetchAll then return @parts.fetchAll()

importDataFromParts = ->
  firstPartWithPublicationDate = @parts.find getPublicationDate
  if firstPartWithPublicationDate?
    @set 'publicationStart', getPublicationDate(firstPartWithPublicationDate)

getUri = _.property 'uri'
getPublicationDate = (model)-> model.get 'claims.wdt:P577.0'
getAuthors = (model)-> model.getExtendedAuthorsUris()
