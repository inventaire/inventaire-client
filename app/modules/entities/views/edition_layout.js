import entityItems from '../lib/entity_items'
import EntityActions from './entity_actions'

export default Marionette.LayoutView.extend({
  template: require('./templates/edition_layout'),
  className: 'edition-commons editionLayout standalone',
  regions: {
    // Prefix regions selectors with 'edition' to avoid collisions with
    // the work own regions
    personalItemsRegion: '.editionPersonalItems',
    networkItemsRegion: '.editionNetworkItems',
    publicItemsRegion: '.editionPublicItems',
    nearbyPublicItemsRegion: '.editionNearbyPublicItems',
    otherPublicItemsRegion: '.editionOtherPublicItems',
    entityActions: '.editionEntityActions',
    works: '.works'
  },

  initialize () {
    this.standalone = true
    this.displayItemsCovers = false
    return entityItems.initialize.call(this)
  },

  onShow () {
    return this.model.waitForWorks
    .map(work => work.fetchSubEntities())
    .then(this.ifViewIsIntact('showWorks'))
  },

  showWorks () {
    const collection = new Backbone.Collection(this.model.works)
    return this.works.show(new EditionWorks({ collection }))
  },

  onRender () {
    this.lazyShowItems()
    this.showEntityActions()
  },

  serializeData () {
    return _.extend(this.model.toJSON(), {
      standalone: this.standalone,
      onWorkLayout: this.options.onWorkLayout,
      works: this.model.works?.map(work => work.toJSON())
    })
  },

  showEntityActions () {
    const { itemToUpdate } = this.options
    return this.entityActions.show(new EntityActions({ model: this.model, itemToUpdate }))
  }
})

const EditionWork = Marionette.ItemView.extend({
  className: 'edition-work',
  template: require('./templates/edition_work')
})

const EditionWorks = Marionette.CollectionView.extend({
  className: 'edition-works',
  childView: EditionWork
})
