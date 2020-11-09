import TypedEntityLayout from './typed_entity_layout'
import EntitiesList from './entities_list'
import { startLoading, stopLoading } from 'modules/general/plugins/behaviors'
import SerieInfobox from './serie_infobox'
import serieLayoutTemplate from './templates/serie_layout.hbs'
import '../scss/serie_layout.scss'

export default TypedEntityLayout.extend({
  template: serieLayoutTemplate,
  Infobox: SerieInfobox,
  baseClassName: 'serieLayout',

  regions: {
    infoboxRegion: '.serieInfobox',
    parts: '.parts',
    mergeSuggestionsRegion: '.mergeSuggestions'
  },

  behaviors: {
    Loading: {}
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

  showParts () {
    stopLoading.call(this)

    return this.parts.show(new EntitiesList({
      parentModel: this.model,
      collection: this.model.partsWithoutSuperparts,
      title: 'works',
      type: 'work',
      hideHeader: true,
      refresh: this.refresh,
      addButtonLabel: 'add a work to this serie'
    }))
  }
})
