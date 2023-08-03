import EntityActions from './entity_actions.js'
import editionLiTemplate from './templates/edition_li.hbs'
import '../scss/edition_commons.scss'
import '../scss/edition_li.scss'

export default Marionette.View.extend({
  template: editionLiTemplate,
  tagName: 'li',
  className: 'edition-commons editionLi',
  regions: {
    // Prefix regions selectors with 'edition' to avoid collisions with
    // the work own regions
    personalItemsRegion: '.editionPersonalItems',
    networkItemsRegion: '.editionNetworkItems',
    publicItemsRegion: '.editionPublicItems',
    nearbyPublicItemsRegion: '.editionNearbyPublicItems',
    otherPublicItemsRegion: '.editionOtherPublicItems',
    entityActions: '.editionEntityActions'
  },

  initialize () {
    ({ itemToUpdate: this.itemToUpdate, compactMode: this.compactMode, onWorkLayout: this.onWorkLayout } = this.options)
  },

  onRender () {
    this.showEntityActions()
  },

  serializeData () {
    return _.extend(this.model.toJSON(), {
      itemUpdateContext: (this.itemToUpdate != null),
      onWorkLayout: this.onWorkLayout,
      compactMode: this.compactMode,
      itemsListsDisabled: this.itemToUpdate || this.compactMode
    })
  },

  showEntityActions () {
    if (!this.compactMode) {
      this.showChildView('entityActions', new EntityActions({ model: this.model, itemToUpdate: this.itemToUpdate }))
    }
  }
})
