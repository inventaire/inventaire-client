import generalInfoboxTemplate from './templates/general_infobox.hbs'

export default Marionette.ItemView.extend({
  className: 'generalInfobox',
  template: generalInfoboxTemplate,
  behaviors: {
    EntitiesCommons: {},
    ClampedExtract: {}
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
    return _.extend(attrs, {
      standalone: this.options.standalone,
      small: this.small,
      showHistoryButton: app.user.hasDataadminAccess,
    })
  }
})
