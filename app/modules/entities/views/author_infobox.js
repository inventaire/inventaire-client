import GeneralInfobox from './general_infobox'
import clampedExtract from '../lib/clamped_extract'
import authorInfoboxTemplate from './templates/author_infobox.hbs'
import '../scss/entities_infoboxes.scss'

export default GeneralInfobox.extend({
  template: authorInfoboxTemplate,
  serializeData () {
    const attrs = this.model.toJSON()
    if (this.options.standalone) {
      attrs.showDeduplicateEntityButton = app.user.hasDataadminAccess
      attrs.showHistoryButton = app.user.hasDataadminAccess
    }
    clampedExtract.setAttributes(attrs)
    attrs.standalone = this.options.standalone
    return attrs
  }
})
