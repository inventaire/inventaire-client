columnWidthBase = 200
gutterBase = 3
containerBase = columnWidthBase + gutterBase
maxColumnWidth = 300


module.exports = Backbone.Marionette.CollectionView.extend
  childView: require './item_figure'
  emptyView: require './no_item'
  tagName: 'div'
  className: 'itemsList jk'

  initialize: ->
    app.execute 'items:pagination:head'
    @lazyMasonry = _.debounce @setMasonry.bind(@), 150

  onShow: ->
    @initMasonery()

  initMasonery: ->
    _.log 'initMasonery'
    @setDimensions()
    @setContainerWidth @columnWidth
    if @severalColumns
      @$el.imagesLoaded @lazyMasonry.bind(@)

  setDimensions: ->
    space = calcSpace @$el.width()
    columns = calcColumn space
    grow = calcGrow space, columns

    @columnWidth = calcColumnWidth grow
    @gutter = calcGutter grow
    @severalColumns = calcSpaceMoreThanOneColumn(space)

  setContainerWidth: (width)->
    $('.itemContainer').width(width)

  setMasonry: ->
    _.log 'setMasonry'
    @$el.masonry
      itemSelector: '.itemContainer'
      isFitWidth: true
      isResizable: true
      isAnimated: true
      gutter: @gutter


calcSpace = (elWidth)->
  space = elWidth
  maxSpace = window.screen.width

  unless _.smallScreen
    sideBar = 250
    maxSpace -= sideBar

  if space < maxSpace then return space
  else return maxSpace

calcColumn = (space)->
  Math.floor(space / (columnWidthBase + gutterBase))

calcGrow = (space, columns)->
  usedSpace = containerBase * columns
  return space / usedSpace

calcColumnWidth = (grow)->
  columnWidth = Math.floor(columnWidthBase * grow)
  if columnWidth < maxColumnWidth then return columnWidth
  else return maxColumnWidth

calcGutter = (grow)-> Math.floor(gutterBase * grow)

calcSpaceMoreThanOneColumn = (space)->
  space > (containerBase * 2)