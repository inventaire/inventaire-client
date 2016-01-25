module.exports = (params)->
  { batchLength, initialLength, fetchMore, more } = params
  batchLength or= 5
  # MUST be called with the CollectionView or CompositeView it extends as context
  unless _.isView @
    throw new Error('should be called with a view as context')

  displayedLimit = initialLength or batchLength
  @lazyRender = _.LazyRender @

  unless fetchMore?
    fetchMore = -> _.preq.resolved
    # if fetchMore is defined in params, more should be too
    more = -> @collection.length > displayedLimit

  _.extend @,
    filter: (child, index, collection)->
      return -1 < index < displayedLimit

    more: more

    displayMore: ->
      fetchMore()
      .then =>
        displayedLimit += batchLength
        @lazyRender()
