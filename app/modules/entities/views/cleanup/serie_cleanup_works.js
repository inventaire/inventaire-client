/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.CompositeView.extend({
  className: 'serie-cleanup-works',
  template: require('./templates/serie_cleanup_works'),
  childViewContainer: '.worksContainer',
  childView: require('./serie_cleanup_work'),
  serializeData () {
    return { sectionLabel: this.options.label }
  },

  filter (child) {
    if (this.options.name !== 'withOrdinal') { return true }
    const ordinal = child.get('ordinal')
    return (ordinal != null) && (ordinal !== 0)
  },

  childViewOptions () { return this.options }
})
