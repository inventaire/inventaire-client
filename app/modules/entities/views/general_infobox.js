import clampedExtract from '../lib/clamped_extract'
import generalInfoboxTemplate from './templates/general_infobox.hbs'
import ClampedExtract from '#behaviors/clamped_extract'
import EntitiesCommons from '#behaviors/entities_commons'

export default Marionette.View.extend({
  className: 'generalInfobox',
  template: generalInfoboxTemplate,
  behaviors: {
    EntitiesCommons,
    ClampedExtract,
  },

  initialize () {
    // Also accept user models that will miss a getWikipediaExtract method
    this.model.getWikipediaExtract?.()
    this.small = this.options.small
  },

  modelEvents: {
    // The extract might arrive later
    'change:extract': 'render'
  },

  serializeData () {
    const attrs = this.model.toJSON()
    // Also accept user models
    if (!attrs.extract) attrs.extract = attrs.bio
    if (!attrs.image) attrs.image = { url: attrs.picture }
    clampedExtract.setAttributes(attrs)
    return _.extend(attrs, {
      standalone: this.options.standalone,
      small: this.small,
    })
  }
})
