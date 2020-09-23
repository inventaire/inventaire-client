/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import GeneralInfobox from 'modules/entities/views/general_infobox'

export default Marionette.LayoutView.extend({
  id: 'inner-filter-preview',
  template: require('./templates/filter_preview'),
  regions: {
    author: '#authorPreview',
    genre: '#genrePreview',
    subject: '#subjectPreview',
    owner: '#ownerPreview'
  },

  ui: {
    authorPreviewHandler: '#authorPreviewHandler',
    genrePreviewHandler: '#genrePreviewHandler',
    subjectPreviewHandler: '#subjectPreviewHandler',
    ownerPreviewHandler: '#ownerPreviewHandler'
  },

  initialize () {
    return this._activeRegions = {}
  },

  events: {
    'click .handler': 'highlightHandlerRegion'
  },

  updatePreview (name, model) {
    if ((model == null) || model.isUnknown) { return this.removePreview(name) }

    const region = this[name]

    if (region == null) { return }

    this._activeRegions[name] = true

    region.show(new GeneralInfobox({ model, small: true }))

    return this.highlightPreview(name)
  },

  highlightPreview (name) {
    this.ui[`${name}PreviewHandler`].addClass('shown')
    this.$el.find('.preview-wrapper.active').removeClass('active')
    // target .preview-wrapper
    this[name].$el.parent().addClass('active')
    return this.$el.addClass('shown')
  },

  removePreview (name) {
    this.ui[`${name}PreviewHandler`].removeClass('shown')
    // target .preview-wrapper
    this[name].$el.parent().removeClass('active')
    delete this._activeRegions[name]
    const fallbackRegion = Object.keys(this._activeRegions)[0]
    if (fallbackRegion != null) {
      return this.highlightPreview(fallbackRegion)
    } else {
      // target .preview-wrapper
      return this.$el.removeClass('shown')
    }
  },

  highlightHandlerRegion (e) {
    const name = e.currentTarget.id.replace('PreviewHandler', '')
    return this.highlightPreview(name)
  }
})
