TypedEntityLayout = require './typed_entity_layout'
EditionsList = require './editions_list'
EntitiesList = require './entities_list'

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
    @collectionsList.show new EntitiesList
      parentModel: @model
      collection: @model.publisherCollections
      title: 'collections'
      type: 'collection'
      showActions: true
      compactMode: true

  showIsolatedEditions: ->
    @editionsList.show new EntitiesList
      parentModel: @model
      collection: @model.isolatedEditions
      title: 'editions'
      type: 'edition'
      showActions: true
      compactMode: true
