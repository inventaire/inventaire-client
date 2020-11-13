import GeneralInfobox from './general_infobox'
import clampedExtract from '../lib/clamped_extract'
import publisherInfoboxTemplate from './templates/publisher_infobox.hbs'
import '../scss/entities_infoboxes.scss'

export default GeneralInfobox.extend({
  template: publisherInfoboxTemplate,
  serializeData () {
    const attrs = this.model.toJSON()
    clampedExtract.setAttributes(attrs)
    attrs.showHistoryButton = app.user.hasDataadminAccess
    return attrs
  }
})
