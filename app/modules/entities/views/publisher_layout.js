import TypedEntityLayout from './typed_entity_layout'
import getEntitiesListView from './entities_list'
import PaginatedEntities from 'modules/entities/collections/paginated_entities'
import PublisherInfobox from './publisher_infobox'
import publisherLayoutTemplate from './templates/publisher_layout.hbs'
import '../scss/entities_layouts.scss'
import '../scss/publisher_layout.scss'

export default TypedEntityLayout.extend({
  id: 'publisherLayout',
  className: 'standalone',
  template: publisherLayoutTemplate,
  Infobox: PublisherInfobox,
  regions: {
    infoboxRegion: '.publisherInfobox',
    collectionsList: '#collectionsList',
    editionsList: '#editionsList',
    mergeSuggestionsRegion: '.mergeSuggestions'
  },

  initialize () {
    this.model.initPublisherPublications()
    this.displayMergeSuggestions = app.user.hasAdminAccess
  },

  async onShow () {
    await this.model.waitForPublications
    if (this.isIntact()) this.showPublications()
  },

  showPublications () {
    this.showCollections()
    this.showIsolatedEditions()
  },

  async showCollections () {
    const uris = this.model.publisherCollectionsUris
    const collection = new PaginatedEntities(null, { uris, defaultType: 'collection' })
    const view = await getEntitiesListView({
      parentModel: this.model,
      collection,
      title: 'collections',
      type: 'collection',
      showActions: true,
      compactMode: true,
      addButtonLabel: 'add a collection from this publisher'
    })
    this.collectionsList.show(view)
  },

  async showIsolatedEditions () {
    const uris = this.model.isolatedEditionsUris
    const collection = new PaginatedEntities(null, { uris, defaultType: 'edition' })
    const view = await getEntitiesListView({
      parentModel: this.model,
      collection,
      title: 'editions',
      type: 'edition',
      showActions: true,
      compactMode: true,
      addButtonLabel: 'add an edition from this publisher'
    })
    this.editionsList.show(view)
  }
})
