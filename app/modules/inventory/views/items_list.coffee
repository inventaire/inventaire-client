module.exports = Backbone.Marionette.CollectionView.extend
  childView: require './item_figure'
  emptyView: require './no_item'
  tagName: 'div'
  className: 'itemsList jk'

  initialize: ->
    app.execute 'items:pagination:head'
    @lazyMasonry = _.debounce @setMasonry.bind(@), 150

  onShow: ->
    @$el.imagesLoaded @lazyMasonry.bind(@)

  setMasonry: ->
    @$el.masonry
      itemSelector: '.itemContainer'
      isFitWidth: true
      isResizable: true
      isAnimated: true
      gutter: 5
