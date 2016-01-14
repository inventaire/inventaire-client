module.exports = (batchLength=5, initialLength)->
  # MUST be called with the CollectionView or CompositeView it extends as context
  unless _.isView @
    throw new Error('should be called with a view as context')

  displayedLimit = initialLength or batchLength
  @lazyRender = _.LazyRender @

  _.extend @,
    filter: (child, index, collection)->
      return -1 < index < displayedLimit

    more: -> @collection.length > displayedLimit

    displayMore: ->
      displayedLimit += batchLength
      @lazyRender()
