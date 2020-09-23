/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import showAllAuthorsPreviewLists from 'modules/entities/lib/show_all_authors_preview_lists'
import clampedExtract from '../lib/clamped_extract'

export default Marionette.LayoutView.extend({
  template: require('./templates/work_infobox'),
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
    setImagesSubGroups(attrs)
    return attrs
  },

  onRender () {
    app.execute('uriLabel:update')

    return this.waitForAuthors
    .then(this.ifViewIsIntact(showAllAuthorsPreviewLists))
  }
})

var setImagesSubGroups = function (attrs) {
  const { images } = attrs
  if (images == null) { return }
  attrs.mainImage = images[0]
  return attrs.secondaryImages = images.slice(1)
}
