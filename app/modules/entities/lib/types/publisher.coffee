filterOutWdEditions = require '../filter_out_wd_editions'
PaginatedEntities = require '../../collections/paginated_entities'

module.exports = ->
  @childrenClaimProperty = 'wdt:P123'
  @subentitiesName = 'editions'
  _.extend @, specificMethods

specificMethods =
  beforeSubEntitiesAdd: filterOutWdEditions

  fetchPublisherPublications: (refresh)->
    if not refresh and @waitForPublicationsData? then return @waitForPublicationsData
    uri = @get 'uri'
    @waitForPublicationsData = _.preq.get app.API.entities.publisherPublications(uri, refresh)

  initPublisherPublications: (refresh)->
    refresh = @getRefresh refresh
    if not refresh and @waitForPublications? then return @waitForPublications

    @waitForPublications = @fetchPublisherPublications refresh
      .then @initPublicationsCollections.bind(@)

  initPublicationsCollections: (publicationsData)->
    { collections, editions } = publicationsData
    collectionsUris = _.pluck(collections, 'uri')

    isolatedEditions = editions.filter isntInAKnownCollection(collectionsUris)
    isolatedEditionsUris = _.pluck isolatedEditions, 'uri'

    @publisherCollections = new PaginatedEntities null, { uris: collectionsUris, defaultType: 'collection' }
    @isolatedEditions = new PaginatedEntities null, { uris: isolatedEditionsUris, defaultType: 'edition' }

isntInAKnownCollection = (collectionsUris)-> (edition)->
  unless edition.collection? then return true
  return edition.collection not in collectionsUris
