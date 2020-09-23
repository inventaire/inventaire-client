/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.CompositeView.extend({
  template: require('./templates/authors_preview_list'),
  childViewContainer: 'ul',
  childView: require('./author_preview'),
  className: 'author-preview-list',
  serializeData () {
    return { name: this.options.name }
  }
})
