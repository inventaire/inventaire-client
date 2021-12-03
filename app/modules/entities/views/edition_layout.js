import entityItems from '../lib/entity_items'
import EntityActions from './entity_actions'
import editionLayoutTemplate from './templates/edition_layout.hbs'
import editionWorkTemplate from './templates/edition_work.hbs'
import '../scss/edition_commons.scss'
import '../scss/edition_layout.scss'

export default Marionette.View.extend({
  template: editionLayoutTemplate,
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
    entityItems.initialize.call(this)
  },

  async onRender () {
    this.model.waitForWorks
    .then(works => works.map(work => work.fetchSubEntities()))
    .then(this.ifViewIsIntact('showWorks'))
    .catch(app.Execute('show:error'))

    this.lazyShowItems()
    this.showEntityActions()
  },

  showWorks () {
    const collection = new Backbone.Collection(this.model.works)
    this.showChildView('works', new EditionWorks({ collection }))
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
    this.showChildView('entityActions', new EntityActions({ model: this.model, itemToUpdate }))
  }
})

const EditionWork = Marionette.View.extend({
  className: 'edition-work',
  template: editionWorkTemplate
})

const EditionWorks = Marionette.CollectionView.extend({
  className: 'edition-works',
  childView: EditionWork
})
