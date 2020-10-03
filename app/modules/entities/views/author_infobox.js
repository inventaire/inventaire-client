import GeneralInfobox from './general_infobox'
import clampedExtract from '../lib/clamped_extract'

export default GeneralInfobox.extend({
  template: require('./templates/author_infobox.hbs'),
  serializeData () {
    const attrs = this.model.toJSON()
    attrs.showDeduplicateEntityButton = app.user.hasDataadminAccess && this.options.standalone
    clampedExtract.setAttributes(attrs)
    attrs.standalone = this.options.standalone
    return attrs
  }
})
