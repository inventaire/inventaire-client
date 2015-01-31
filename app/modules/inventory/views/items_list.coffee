module.exports = class ItemsList extends Backbone.Marionette.CollectionView
  childView: require './item_figure'
  getEmptyView: ->
    if @options.welcomingNoItem then require './welcoming_no_item'
    else require './no_item'
  tagName: 'div'
  className: ->
    classes = 'itemsList jk'
    if @options.columns then classes += ' columnsLayout'
    return classes