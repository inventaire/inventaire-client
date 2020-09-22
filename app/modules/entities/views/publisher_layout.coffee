TypedEntityLayout = require './typed_entity_layout'
EditionsList = require './editions_list'
EntitiesList = require './entities_list'
PaginatedEntities = require 'modules/entities/collections/paginated_entities'

module.exports = TypedEntityLayout.extend
  id: 'publisherLayout'
  className: 'standalone'
  template: require './templates/publisher_layout'
  Infobox: require './publisher_infobox'
  regions:
    infoboxRegion: '.publisherInfobox'
    collectionsList: '#collectionsList'
    editionsList: '#editionsList'
    mergeSuggestionsRegion: '.mergeSuggestions'

  initialize: ->
    @model.initPublisherPublications()

  onShow: ->
    @model.waitForPublications
    .then @ifViewIsIntact('showPublications')

  showPublications: ->
    @showCollections()
    @showIsolatedEditions()

  showCollections: ->
    uris = @model.publisherCollectionsUris
    collection = new PaginatedEntities null, { uris, defaultType: 'collection' }
    @collectionsList.show new EntitiesList
      parentModel: @model
      collection: collection
      title: 'collections'
      type: 'collection'
      showActions: true
      compactMode: true
      addButtonLabel: 'add a collection from this publisher'

  showIsolatedEditions: ->
    uris = @model.isolatedEditionsUris
    collection = new PaginatedEntities null, { uris, defaultType: 'edition' }
    @editionsList.show new EntitiesList
      parentModel: @model
      collection: collection
      title: 'editions'
      type: 'edition'
      showActions: true
      compactMode: true
      addButtonLabel: 'add an edition from this publisher'
