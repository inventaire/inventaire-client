import SerieCleanupEdition from './serie_cleanup_edition.js'

export default Marionette.CollectionView.extend({
  tagName: 'ul',
  childView: SerieCleanupEdition,
  childViewOptions () {
    return {
      worksWithOrdinal: this.options.worksWithOrdinal,
      worksWithoutOrdinal: this.options.worksWithoutOrdinal
    }
  },
  // Keeping a consistent sorting function so that rolling back an edition
  // puts it back at the same spot
  viewComparator: 'label',
  // Filter-out composite editions as it would be a mess to handle the work picker
  // with several existing work claims
  viewFilter (child) {
    return child.model.get('claims.wdt:P629')?.length === 1
  }
})
