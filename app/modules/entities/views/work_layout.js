import TypedEntityLayout from './typed_entity_layout';
import EditionsList from './editions_list';
import EntityActions from './entity_actions';
import entityItems from '../lib/entity_items';

export default TypedEntityLayout.extend({
  id: 'workLayout',
  Infobox: require('./work_infobox'),
  template: require('./templates/work_layout'),
  regions: {
    infoboxRegion: '#workInfobox',
    editionsList: '#editionsList',
    // Prefix regions selectors with 'work' to avoid collisions with editions
    // displayed as sub-views
    entityActions: '.workEntityActions',
    personalItemsRegion: '.workPersonalItems',
    networkItemsRegion: '.workNetworkItems',
    publicItemsRegion: '.workPublicItems',
    nearbyPublicItemsRegion: '.workNearbyPublicItems',
    otherPublicItemsRegion: '.workOtherPublicItems',
    mergeSuggestionsRegion: '.mergeSuggestions'
  },

  initialize() {
    this.displayItemsCovers = true;
    TypedEntityLayout.prototype.initialize.call(this);
    entityItems.initialize.call(this);
    return this.displayMergeSuggestions = app.user.hasAdminAccess;
  },

  onRender() {
    TypedEntityLayout.prototype.onRender.call(this);
    return this.lazyShowItems();
  },

  serializeData() {
    return _.extend(this.model.toJSON(),
      {displayMergeSuggestions: this.displayMergeSuggestions});
  },

  onShow() {
    // Need to wait to know if the user has an instance of this work
    this.waitForItems
    .then(this.ifViewIsIntact('showEntityActions'));

    return this.model.fetchSubEntities()
    .then(this.ifViewIsIntact('showEditions'));
  },

  events: {
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'
  },

  showEntityActions() { return this.entityActions.show(new EntityActions({ model: this.model })); },

  showEditions() {
    return this.editionsList.show(new EditionsList({
      collection: this.model.editions,
      work: this.model,
      onWorkLayout: true
    })
    );
  },

  toggleWikipediaPreview() { return this.$el.trigger('toggleWikiIframe', this); },

  showMergeSuggestions() {
    return app.execute('show:merge:suggestions', { model: this.model, region: this.mergeSuggestionsRegion });
  }});
