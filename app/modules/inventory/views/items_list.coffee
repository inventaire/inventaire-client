module.exports = Backbone.Marionette.CollectionView.extend
  childView: require './item_figure'
  emptyView: require './no_item'
  tagName: 'div'
  className: ->
    classes = 'itemsList jk'
    if @options.columns then classes += ' columnsLayout'
    return classes

  initialize: -> app.execute 'items:pagination:head'
