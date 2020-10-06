import GeneralInfobox from './general_infobox'
import clampedExtract from '../lib/clamped_extract'
import publisherInfoboxTemplate from './templates/publisher_infobox.hbs'

export default GeneralInfobox.extend({
  template: publisherInfoboxTemplate,
  serializeData () {
    const attrs = this.model.toJSON()
    clampedExtract.setAttributes(attrs)
    return attrs
  }
})
