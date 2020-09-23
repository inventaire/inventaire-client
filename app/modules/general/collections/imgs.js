/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Backbone.Collection.extend({
  model: require('../models/img'),
  invalidImage (model, err) {
    this.remove(model)
    return this.trigger('invalid:image', err)
  }
})
