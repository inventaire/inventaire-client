filterOutWdEditions = require '../filter_out_wd_editions'

module.exports = ->
  @childrenClaimProperty = 'wdt:P123'
  @subentitiesName = 'editions'
  _.extend @, specificMethods

specificMethods =
  beforeSubEntitiesAdd: filterOutWdEditions

  initPublisherPublications: (refresh)->
    refresh = @getRefresh refresh
    if not refresh and @waitForPublications? then return @waitForPublications

    @waitForPublications = @fetchPublisherPublications refresh
      .then @initPublicationsCollections.bind(@)

  fetchPublisherPublications: (refresh)->
    if not refresh and @waitForPublicationsData? then return @waitForPublicationsData
    uri = @get 'uri'
    @waitForPublicationsData = _.preq.get app.API.entities.publisherPublications(uri, refresh)

  initPublicationsCollections: (publicationsData)->
    { collections, editions } = publicationsData
    @publisherCollectionsUris = _.pluck(collections, 'uri')
    isolatedEditions = editions.filter isntInAKnownCollection(@publisherCollectionsUris)
    @isolatedEditionsUris = _.pluck isolatedEditions, 'uri'

isntInAKnownCollection = (collectionsUris)-> (edition)->
  unless edition.collection? then return true
  return edition.collection not in collectionsUris
