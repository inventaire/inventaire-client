/* eslint-disable
    import/no-duplicates,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import GeneralInfobox from './general_infobox'
import clampedExtract from '../lib/clamped_extract'

export default GeneralInfobox.extend({
  template: require('./templates/publisher_infobox'),
  serializeData () {
    const attrs = this.model.toJSON()
    clampedExtract.setAttributes(attrs)
    return attrs
  }
})
