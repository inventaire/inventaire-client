# dependencies: behaviorsPlugin, paginationPlugin

module.exports = (containerUiName, itemSelector, minWidth=500)->
  # MUST be called with the View it extends as context
  unless _.isView(@)
    throw new Error('should be called with a view as context')

  initMasonry = ->
    unless window.screen.width < minWidth
      @ui[containerUiName].masonry
        itemSelector: itemSelector
        isFitWidth: true
        isResizable: true
        isAnimated: true
        gutter: 5

  refresh = ->
    _.log 'masonry:refresh'
    # wait for images to be loaded
    @ui[containerUiName].imagesLoaded initMasonry.bind(@)
    # trigger a stopLoading event: only useful after infiniteScroll startLoading
    # @stopLoading()

  lazyRefresh = _.debounce refresh.bind(@), 200

  @on 'render:collection', lazyRefresh.bind(@)

  return