/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.Region.extend({
  attachHtml (view) {
    // uses the fake region el to have it's own el
    // inserted just after the fake region
    return $(view.el).insertAfter(this.$el)
  }
})
