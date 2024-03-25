import SerieCleanupWork from './serie_cleanup_work.ts'
import serieCleanupWorksTemplate from './templates/serie_cleanup_works.hbs'

export default Marionette.CollectionView.extend({
  className: 'serie-cleanup-works',
  template: serieCleanupWorksTemplate,
  childViewContainer: '.worksContainer',
  childView: SerieCleanupWork,
  serializeData () {
    return { sectionLabel: this.options.label }
  },

  viewFilter (child) {
    if (this.options.name !== 'withOrdinal') return true
    const ordinal = child.model.get('ordinal')
    return (ordinal != null) && (ordinal !== 0)
  },

  childViewOptions () { return this.options },
})
