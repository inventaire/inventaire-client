/* eslint-disable
    import/no-duplicates,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import TypedEntityLayout from './typed_entity_layout'
import EntitiesList from './entities_list'
import { startLoading, stopLoading } from 'modules/general/plugins/behaviors'

export default TypedEntityLayout.extend({
  template: require('./templates/serie_layout'),
  Infobox: require('./serie_infobox'),
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
    return this.$el.once('inview', this.fetchParts.bind(this))
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
    })
    )
  }
})
