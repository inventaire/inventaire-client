import showAllAuthorsPreviewLists from 'modules/entities/lib/show_all_authors_preview_lists'
import clampedExtract from '../lib/clamped_extract'
import serieInfoboxTemplate from './templates/serie_infobox.hbs'

export default Marionette.LayoutView.extend({
  template: serieInfoboxTemplate,
  className: 'serieInfobox',
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
    this.model.getWikipediaExtract()
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
    attrs.showHistoryButton = app.user.hasDataadminAccess
    return attrs
  },

  async onRender () {
    const authorsPerProperty = await this.waitForAuthors
    if (this.isIntact()) showAllAuthorsPreviewLists.call(this, authorsPerProperty)
  }
})
