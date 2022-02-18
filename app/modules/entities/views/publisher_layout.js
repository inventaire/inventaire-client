import TypedEntityLayout from './typed_entity_layout.js'
import getEntitiesListView from './entities_list.js'
import PaginatedEntities from '#modules/entities/collections/paginated_entities'
import PublisherInfobox from './publisher_infobox.js'
import publisherLayoutTemplate from './templates/publisher_layout.hbs'
import '../scss/entities_layouts.scss'
import '../scss/publisher_layout.scss'

export default TypedEntityLayout.extend({
  id: 'publisherLayout',
  className: 'standalone',
  tagName () {
    return this.options.tagName || 'div'
  },
  template: publisherLayoutTemplate,
  Infobox: PublisherInfobox,
  regions: {
    infoboxRegion: '.publisherInfobox',
    collectionsList: '#collectionsList',
    editionsList: '#editionsList',
    mergeHomonymsRegion: '.mergeHomonyms'
  },

  initialize () {
    this.model.initPublisherPublications()
    this.displayMergeSuggestions = app.user.hasAdminAccess
  },

  async onRender () {
    TypedEntityLayout.prototype.onRender.call(this)
    await this.model.waitForPublications
    if (!this.isIntact()) return
    this.showPublications()
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
    this.showChildView('collectionsList', view)
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
    this.showChildView('editionsList', view)
  }
})
