/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'text-center hidden',
  template: require('./templates/no_user'),

  onShow () { return this.$el.fadeIn() },

  serializeData () {
    return { message: this.options.message || "can't find anyone with that name" }
  }
})
