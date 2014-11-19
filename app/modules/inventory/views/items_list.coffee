module.exports = class ItemsList extends Backbone.Marionette.CollectionView
  childView: require './item_figure'
  emptyView: require './no_item'
  tagName: 'div'
  className: ->
    classes = 'itemsList jk'
    if @options.columns then classes += ' columnsLayout'
    return classes