/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Backbone.Collection.extend({
  comparator (model) {
    // Push the 'unknown' entity at the bottom of the list
    if (model.get('uri') === 'unknown') {
      return Infinity
    } else { return -model.get('count') }
  }
})
