import showAllAuthorsPreviewLists from 'modules/entities/lib/show_all_authors_preview_lists'
import clampedExtract from '../lib/clamped_extract'
import workInfoboxTemplate from './templates/work_infobox.hbs'
import ClampedExtract from 'behaviors/clamped_extract'
import EntitiesCommons from 'behaviors/entities_commons'
import PreventDefault from 'behaviors/prevent_default'

export default Marionette.View.extend({
  template: workInfoboxTemplate,
  className: 'workInfobox',
  regions: {
    authors: '.authors',
    scenarists: '.scenarists',
    illustrators: '.illustrators',
    colorists: '.colorists'
  },

  behaviors: {
    ClampedExtract,
    EntitiesCommons,
    PreventDefault,
  },

  initialize (options) {
    this.hidePicture = options.hidePicture
    this.waitForAuthors = this.model.getExtendedAuthorsModels()
    this.model.getWikipediaExtract()
  },

  modelEvents: {
    change: 'lazyRender'
  },

  serializeData () {
    const attrs = this.model.toJSON()
    clampedExtract.setAttributes(attrs)
    attrs.standalone = this.options.standalone
    attrs.hidePicture = this.hidePicture
    setImagesSubGroups(attrs)
    return attrs
  },

  async onRender () {
    app.execute('uriLabel:update')

    const authorsPerProperty = await this.waitForAuthors
    if (this.isIntact()) showAllAuthorsPreviewLists.call(this, authorsPerProperty)
  }
})

const setImagesSubGroups = function (attrs) {
  const { images } = attrs
  if (images == null) return
  attrs.mainImage = images[0]
  attrs.secondaryImages = images.slice(1)
}
