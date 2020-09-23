/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Backbone.Model.extend({
  initialize () {
    return this.reqGrab('get:user:model', this.get('user'), 'user')
  },

  serializeData () {
    return _.extend(this.toJSON(),
      { user: this.user?.serializeData() })
  }
})
