import SerieCleanupWork from './serie_cleanup_work'
import serieCleanupWorksTemplate from './templates/serie_cleanup_works.hbs'

export default Marionette.CompositeView.extend({
  className: 'serie-cleanup-works',
  template: serieCleanupWorksTemplate,
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
