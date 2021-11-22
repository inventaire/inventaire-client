import TypedEntityLayout from './typed_entity_layout'
import getEntitiesListView from './entities_list'
import GeneralInfobox from './general_infobox'
import PaginatedEntities from 'modules/entities/collections/paginated_entities'
import collectionLayoutTemplate from './templates/collection_layout.hbs'
import collectionInfoboxTemplate from './templates/collection_infobox.hbs'
import '../scss/entities_layouts.scss'
import '../scss/entities_infoboxes.scss'
import '../scss/collection_layout.scss'

const Infobox = GeneralInfobox.extend({ template: collectionInfoboxTemplate })

export default TypedEntityLayout.extend({
  baseClassName: 'collectionLayout',
  tagName () {
    return this.options.tagName || 'div'
  },
  template: collectionLayoutTemplate,
  Infobox,
  regions: {
    infoboxRegion: '.collectionInfobox',
    editionsList: '#editionsList',
    mergeHomonymsRegion: '.mergeHomonyms'
  },

  onRender () {
    this.model.fetchSubEntitiesUris(this.refresh)
    .then(this.ifViewIsIntact('showPaginatedEditions'))
  },

  serializeData () {
    return { standalone: this.standalone }
  },

  async showPaginatedEditions (uris) {
    const collection = new PaginatedEntities(null, { uris, defaultType: 'edition' })
    const view = await getEntitiesListView({
      collection,
      hideHeader: !this.standalone,
      compactMode: true,
      parentModel: this.model,
      type: 'edition',
      title: 'editions',
      addButtonLabel: 'add an edition to this collection'
    })
    this.showChildView('editionsList', view)
  }
})
