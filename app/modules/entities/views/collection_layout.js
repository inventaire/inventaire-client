import TypedEntityLayout from './typed_entity_layout';
import EntitiesList from './entities_list';
import GeneralInfobox from './general_infobox';
import PaginatedEntities from 'modules/entities/collections/paginated_entities';

const Infobox = GeneralInfobox.extend({
  template: require('./templates/collection_infobox.hbs')});

export default TypedEntityLayout.extend({
  baseClassName: 'collectionLayout',
  template: require('./templates/collection_layout'),
  Infobox,
  regions: {
    infoboxRegion: '.collectionInfobox',
    editionsList: '#editionsList',
    mergeSuggestionsRegion: '.mergeSuggestions'
  },

  onShow() {
    return this.model.fetchSubEntitiesUris(this.refresh)
    .then(this.ifViewIsIntact('showPaginatedEditions'));
  },

  serializeData() {
    return {standalone: this.standalone};
  },

  showPaginatedEditions(uris){
    const collection = new PaginatedEntities(null, { uris, defaultType: 'edition' });
    return this.editionsList.show(new EntitiesList({
      collection,
      hideHeader: !this.standalone,
      compactMode: true,
      parentModel: this.model,
      type: 'edition',
      title: 'editions',
      addButtonLabel: 'add an edition to this collection'
    })
    );
  }
});
