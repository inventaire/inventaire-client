/* eslint-disable
    import/no-duplicates,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import showAllAuthorsPreviewLists from 'modules/entities/lib/show_all_authors_preview_lists'
import clampedExtract from '../lib/clamped_extract'

export default Marionette.LayoutView.extend({
  template: require('./templates/serie_infobox'),
  behaviors: {
    EntitiesCommons: {},
    ClampedExtract: {}
  },

  regions: {
    authors: '.authors',
    scenarists: '.scenarists',
    illustrators: '.illustrators',
    colorists: '.colorists'
  },

  initialize () {
    this.waitForAuthors = this.model.getExtendedAuthorsModels()
    return this.model.getWikipediaExtract()
  },

  modelEvents: {
    // The description might be overriden by a Wikipedia extract arrive later
    'change:description': 'render'
  },

  serializeData () {
    const attrs = this.model.toJSON()
    clampedExtract.setAttributes(attrs)
    attrs.standalone = this.options.standalone
    attrs.showCleanupButton = app.user.hasDataadminAccess
    return attrs
  },

  onRender () {
    return this.waitForAuthors
    .then(this.ifViewIsIntact(showAllAuthorsPreviewLists))
  }
})
