# dependencies: behaviorsPlugin, paginationPlugin

module.exports = (containerSelector, itemSelector, minWidth=500)->
  # MUST be called with the View it extends as context
  unless _.isView(@)
    throw new Error('should be called with a view as context')

  initMasonry = ->
    unless window.screen.width < minWidth
      container = document.querySelector containerSelector
      new Masonry container,
        itemSelector: itemSelector
        isFitWidth: true
        isResizable: true
        isAnimated: true
        gutter: 5

  refresh = ->
    _.log 'masonry:refresh'
    # wait for images to be loaded
    $(containerSelector).imagesLoaded initMasonry

  @lazyMasonryRefresh = _.debounce refresh, 200

  return