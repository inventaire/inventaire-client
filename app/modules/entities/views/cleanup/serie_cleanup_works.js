import SerieCleanupWork from './serie_cleanup_work'
export default Marionette.CompositeView.extend({
  className: 'serie-cleanup-works',
  template: require('./templates/serie_cleanup_works.hbs'),
  childViewContainer: '.worksContainer',
  childView: SerieCleanupWork,
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
