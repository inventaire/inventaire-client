/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.Behavior.extend({
  ui: {
    extract: '.extract',
    togglers: '.toggler i'
  },

  events: {
    'click .toggler': 'toggleExtractLength'
  },

  toggleExtractLength () {
    this.ui.extract.toggleClass('clamped')
    return this.ui.togglers.toggleClass('hidden')
  }
})
