/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Backbone.Collection.extend({
  comparator (model) {
    // messages have a 'created' date
    // actions have a 'timestamp' date
    return model.get('created') || model.get('timestamp')
  }
})
