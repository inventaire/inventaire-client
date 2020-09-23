/* eslint-disable
    no-return-assign,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Backbone.Collection.extend({
  model: require('../models/shelf'),

  initialize (models, options = {}) {
    return this.selected = options.selected || []
  },

  comparator (shelf) {
    if (this.selected.includes(shelf.id)) {
      return '0' + shelf.get('name').toLowerCase()
    } else { return '1' + shelf.get('name').toLowerCase() }
  }
})
