/* eslint-disable
    import/no-duplicates,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import GeneralInfobox from './general_infobox'
import clampedExtract from '../lib/clamped_extract'

export default GeneralInfobox.extend({
  template: require('./templates/author_infobox'),
  serializeData () {
    const attrs = this.model.toJSON()
    attrs.showDeduplicateEntityButton = app.user.hasDataadminAccess && this.options.standalone
    clampedExtract.setAttributes(attrs)
    attrs.standalone = this.options.standalone
    return attrs
  }
})
