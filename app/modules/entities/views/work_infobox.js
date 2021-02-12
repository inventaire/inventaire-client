import showAllAuthorsPreviewLists from 'modules/entities/lib/show_all_authors_preview_lists'
import clampedExtract from '../lib/clamped_extract'
import workInfoboxTemplate from './templates/work_infobox.hbs'

export default Marionette.LayoutView.extend({
  template: workInfoboxTemplate,
  className: 'workInfobox flex-column-center-center',
  regions: {
    authors: '.authors',
    scenarists: '.scenarists',
    illustrators: '.illustrators',
    colorists: '.colorists'
  },

  behaviors: {
    PreventDefault: {},
    EntitiesCommons: {},
    ClampedExtract: {}
  },

  initialize (options) {
    this.hidePicture = options.hidePicture
    this.waitForAuthors = this.model.getExtendedAuthorsModels()
    return this.model.getWikipediaExtract()
  },

  modelEvents: {
    change: 'lazyRender'
  },

  serializeData () {
    const attrs = this.model.toJSON()
    clampedExtract.setAttributes(attrs)
    attrs.standalone = this.options.standalone
    attrs.hidePicture = this.hidePicture
    attrs.showHistoryButton = this.options.standalone && app.user.hasDataadminAccess
    setImagesSubGroups(attrs)
    return attrs
  },

  async onRender () {
    app.execute('uriLabel:update')

    await this.waitForAuthors
    if (this.isIntact()) showAllAuthorsPreviewLists.call(this)
  }
})

const setImagesSubGroups = function (attrs) {
  const { images } = attrs
  if (images == null) return
  attrs.mainImage = images[0]
  attrs.secondaryImages = images.slice(1)
}
