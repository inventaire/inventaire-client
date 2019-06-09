module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: require './serie_cleanup_edition'
  childViewOptions: ->
    worksWithOrdinal: @options.worksWithOrdinal
  # Keeping a consistent sorting function so that rolling back an edition
  # puts it back at the same spot
  viewComparator: 'label'
  # Filter-out composite editions as it would be a mess to handle the work picker
  # with several existing work claims
  filter: (child)-> child.get('claims.wdt:P629')?.length is 1
