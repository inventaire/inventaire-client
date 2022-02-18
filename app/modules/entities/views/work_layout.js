import TypedEntityLayout from './typed_entity_layout.js'
import EditionsList from './editions_list.js'
import EntityActions from './entity_actions.js'
import entityItems from '../lib/entity_items.js'
import WorkInfobox from './work_infobox.js'
import workLayoutTemplate from './templates/work_layout.hbs'
import '../scss/entities_layouts.scss'
import '../scss/work_layout.scss'

export default TypedEntityLayout.extend({
  id: 'workLayout',
  Infobox: WorkInfobox,
  template: workLayoutTemplate,
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
    mergeHomonymsRegion: '.mergeHomonyms'
  },

  initialize () {
    this.displayItemsCovers = true
    TypedEntityLayout.prototype.initialize.call(this)
    entityItems.initialize.call(this)
    this.displayMergeSuggestions = app.user.hasAdminAccess
  },

  onRender () {
    TypedEntityLayout.prototype.onRender.call(this)
    this.lazyShowItems()

    // Need to wait to know if the user has an instance of this work
    this.waitForItems
    .then(this.ifViewIsIntact('showEntityActions'))

    this.model.fetchSubEntities()
    .then(this.ifViewIsIntact('showEditions'))
  },

  serializeData () {
    return _.extend(this.model.toJSON(), {
      displayMergeSuggestions: this.displayMergeSuggestions
    })
  },

  events: {
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'
  },

  showEntityActions () {
    this.showChildView('entityActions', new EntityActions({ model: this.model }))
  },

  showEditions () {
    this.showChildView('editionsList', new EditionsList({
      collection: this.model.editions,
      work: this.model,
      onWorkLayout: true
    }))
  },

  toggleWikipediaPreview () { this.$el.trigger('toggleWikiIframe', this) },

  showHomonyms () {
    app.execute('show:homonyms', { model: this.model, layout: this, regionName: 'mergeHomonymsRegion' })
  }
})
