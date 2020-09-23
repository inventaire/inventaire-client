# Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.collectionview.coffee

# keep in sync with app/modules/general/scss/_autocomplete.scss
listHeight = 170

module.exports = Marionette.CompositeView.extend
  template: require './templates/autocomplete_suggestions'
  className: 'autocomplete-suggestions'
  childViewContainer: '.results'
  childView: require './autocomplete_suggestion'
  emptyView: require './autocomplete_no_suggestion'
  ui:
    resultsWrapper: '.resultsWrapper'
    results: '.results'
    loader: '.loaderWrapper'

  childEvents:
    'highlight': 'scrollToHighlightedChild'
    'select:from:click': 'selectFromClick'

  scrollToHighlightedChild: (child)->
    childTop = child.$el.position().top
    childBottom = childTop + child.$el.height()
    listPosition = @ui.resultsWrapper.scrollTop()
    if childTop < 0 or childBottom > listHeight
      @ui.resultsWrapper.animate { scrollTop: listPosition + childTop - 20 }

  # Pass the child view event to the filtered collection
  selectFromClick: (e, model)-> @collection.trigger 'select:from:click', model

  onShow: ->
    # Doesn't work if set in events for some reason
    @ui.resultsWrapper.on 'scroll', @onResultsScroll.bind(@)

  onResultsScroll: (e)->
    visibleHeight = @ui.resultsWrapper.height()
    { scrollHeight, scrollTop } = e.currentTarget
    scrollBottom = scrollTop + visibleHeight
    if scrollBottom is scrollHeight then @loadMore()

  loadMore: ->
    @collection.trigger 'load:more'

  showLoadingSpinner: ->
    @ui.loader.html '<div class="small-loader"></div>'
    @$el.removeClass 'no-results'

  stopLoadingSpinner: -> @ui.loader.html ''
