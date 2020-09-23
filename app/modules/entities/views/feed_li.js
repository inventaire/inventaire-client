/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.ItemView.extend({
  template: require('./templates/feed_li'),
  className: 'feedLi',
  modelEvents: {
    // Required for entity that deduce their label from another entity (e.g. edtions)
    change: 'render'
  }
})
