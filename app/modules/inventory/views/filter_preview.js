import GeneralInfobox from 'modules/entities/views/general_infobox'
import filterPreviewTemplate from './templates/filter_preview.hbs'

export default Marionette.View.extend({
  id: 'inner-filter-preview',
  template: filterPreviewTemplate,
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
    this._activeRegions = {}
  },

  events: {
    'click .handler': 'highlightHandlerRegion'
  },

  updatePreview (name, model) {
    if ((model == null) || model.isUnknown) return this.removePreview(name)

    const region = this.getRegion(name)

    if (region == null) return

    this._activeRegions[name] = true

    this.showChildView(name, new GeneralInfobox({ model, small: true }))

    this.highlightPreview(name)
  },

  highlightPreview (name) {
    this.ui[`${name}PreviewHandler`].addClass('shown')
    this.$el.find('.preview-wrapper.active').removeClass('active')
    // target .preview-wrapper
    this.getRegion(name).$el.parent().addClass('active')
    this.$el.addClass('shown')
  },

  removePreview (name) {
    this.ui[`${name}PreviewHandler`].removeClass('shown')
    // target .preview-wrapper
    this.getRegion(name).$el.parent().removeClass('active')
    delete this._activeRegions[name]
    const fallbackRegion = Object.keys(this._activeRegions)[0]
    if (fallbackRegion != null) {
      return this.highlightPreview(fallbackRegion)
    } else {
      // target .preview-wrapper
      this.$el.removeClass('shown')
    }
  },

  highlightHandlerRegion (e) {
    const name = e.currentTarget.id.replace('PreviewHandler', '')
    return this.highlightPreview(name)
  }
})
