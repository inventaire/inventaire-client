module.exports = Marionette.CollectionView.extend
  className: 'deduplicateWorks'
  childView: require './work_li'
  tagName: 'ul'
  # Lazy empty view: not really fitting the context
  # but just showing that nothing was found
  emptyView: require 'modules/inventory/views/no_item'
