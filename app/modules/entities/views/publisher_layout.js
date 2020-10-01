import TypedEntityLayout from './typed_entity_layout'
import EntitiesList from './entities_list'
import PaginatedEntities from 'modules/entities/collections/paginated_entities'

export default TypedEntityLayout.extend({
  id: 'publisherLayout',
  className: 'standalone',
  template: require('./templates/publisher_layout'),
  Infobox: require('./publisher_infobox'),
  regions: {
    infoboxRegion: '.publisherInfobox',
    collectionsList: '#collectionsList',
    editionsList: '#editionsList',
    mergeSuggestionsRegion: '.mergeSuggestions'
  },

  initialize () {
    return this.model.initPublisherPublications()
  },

  onShow () {
    return this.model.waitForPublications
    .then(this.ifViewIsIntact('showPublications'))
  },

  showPublications () {
    this.showCollections()
    this.showIsolatedEditions()
  },

  showCollections () {
    const uris = this.model.publisherCollectionsUris
    const collection = new PaginatedEntities(null, { uris, defaultType: 'collection' })
    return this.collectionsList.show(new EntitiesList({
      parentModel: this.model,
      collection,
      title: 'collections',
      type: 'collection',
      showActions: true,
      compactMode: true,
      addButtonLabel: 'add a collection from this publisher'
    })
    )
  },

  showIsolatedEditions () {
    const uris = this.model.isolatedEditionsUris
    const collection = new PaginatedEntities(null, { uris, defaultType: 'edition' })
    return this.editionsList.show(new EntitiesList({
      parentModel: this.model,
      collection,
      title: 'editions',
      type: 'edition',
      showActions: true,
      compactMode: true,
      addButtonLabel: 'add an edition from this publisher'
    })
    )
  }
})
