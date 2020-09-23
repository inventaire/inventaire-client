import GeneralInfobox from './general_infobox';
import clampedExtract from '../lib/clamped_extract';

export default GeneralInfobox.extend({
  template: require('./templates/publisher_infobox'),
  serializeData() {
    const attrs = this.model.toJSON();
    clampedExtract.setAttributes(attrs);
    return attrs;
  }
});
