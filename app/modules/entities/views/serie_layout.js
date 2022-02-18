import TypedEntityLayout from './typed_entity_layout.js'
import getEntitiesListView from './entities_list.js'
import { startLoading, stopLoading } from '#general/plugins/behaviors'
import SerieInfobox from './serie_infobox.js'
import serieLayoutTemplate from './templates/serie_layout.hbs'
import '../scss/serie_layout.scss'
import Loading from '#behaviors/loading'

export default TypedEntityLayout.extend({
  template: serieLayoutTemplate,
  Infobox: SerieInfobox,
  baseClassName: 'serieLayout',
  tagName () {
    return this.options.tagName || 'div'
  },

  regions: {
    infoboxRegion: '.serieInfobox',
    parts: '.parts',
    mergeHomonymsRegion: '.mergeHomonyms'
  },

  behaviors: {
    Loading,
  },

  initialize () {
    TypedEntityLayout.prototype.initialize.call(this)
    // Trigger fetchParts only once the author is in view
    this.$el.once('inview', this.fetchParts.bind(this))
  },

  fetchParts () {
    startLoading.call(this)

    return this.model.initSerieParts({ refresh: this.refresh })
    .then(this.ifViewIsIntact('showParts'))
  },

  async showParts () {
    stopLoading.call(this)

    const view = await getEntitiesListView({
      parentModel: this.model,
      collection: this.model.partsWithoutSuperparts,
      title: 'works',
      type: 'work',
      hideHeader: true,
      refresh: this.refresh,
      addButtonLabel: 'add a work to this series'
    })

    this.showChildView('parts', view)
  }
})
