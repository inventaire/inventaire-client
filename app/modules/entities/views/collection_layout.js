import TypedEntityLayout from './typed_entity_layout'
import EntitiesList from './entities_list'
import GeneralInfobox from './general_infobox'
import PaginatedEntities from 'modules/entities/collections/paginated_entities'
import collectionLayoutTemplate from './templates/collection_layout.hbs'
import collectionInfoboxTemplate from './templates/collection_infobox.hbs'

const Infobox = GeneralInfobox.extend({ template: collectionInfoboxTemplate })

export default TypedEntityLayout.extend({
  baseClassName: 'collectionLayout',
  template: collectionLayoutTemplate,
  Infobox,
  regions: {
    infoboxRegion: '.collectionInfobox',
    editionsList: '#editionsList',
    mergeSuggestionsRegion: '.mergeSuggestions'
  },

  onShow () {
    return this.model.fetchSubEntitiesUris(this.refresh)
    .then(this.ifViewIsIntact('showPaginatedEditions'))
  },

  serializeData () {
    return { standalone: this.standalone }
  },

  showPaginatedEditions (uris) {
    const collection = new PaginatedEntities(null, { uris, defaultType: 'edition' })
    return this.editionsList.show(new EntitiesList({
      collection,
      hideHeader: !this.standalone,
      compactMode: true,
      parentModel: this.model,
      type: 'edition',
      title: 'editions',
      addButtonLabel: 'add an edition to this collection'
    }))
  }
})
