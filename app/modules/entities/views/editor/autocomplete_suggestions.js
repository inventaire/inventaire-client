// Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.collectionview.js

// keep in sync with app/modules/general/scss/_autocomplete.scss
const listHeight = 170

export default Marionette.CompositeView.extend({
  template: require('./templates/autocomplete_suggestions.hbs'),
  className: 'autocomplete-suggestions',
  childViewContainer: '.results',
  childView: require('./autocomplete_suggestion'),
  emptyView: require('./autocomplete_no_suggestion'),
  ui: {
    resultsWrapper: '.resultsWrapper',
    results: '.results',
    loader: '.loaderWrapper'
  },

  childEvents: {
    highlight: 'scrollToHighlightedChild',
    'select:from:click': 'selectFromClick'
  },

  scrollToHighlightedChild (child) {
    const childTop = child.$el.position().top
    const childBottom = childTop + child.$el.height()
    const listPosition = this.ui.resultsWrapper.scrollTop()
    if ((childTop < 0) || (childBottom > listHeight)) {
      this.ui.resultsWrapper.animate({ scrollTop: (listPosition + childTop) - 20 })
    }
  },

  // Pass the child view event to the filtered collection
  selectFromClick (e, model) { return this.collection.trigger('select:from:click', model) },

  onShow () {
    // Doesn't work if set in events for some reason
    this.ui.resultsWrapper.on('scroll', this.onResultsScroll.bind(this))
  },

  onResultsScroll (e) {
    const visibleHeight = this.ui.resultsWrapper.height()
    const { scrollHeight, scrollTop } = e.currentTarget
    const scrollBottom = scrollTop + visibleHeight
    if (scrollBottom === scrollHeight) { return this.loadMore() }
  },

  loadMore () {
    return this.collection.trigger('load:more')
  },

  showLoadingSpinner () {
    this.ui.loader.html('<div class="small-loader"></div>')
    this.$el.removeClass('no-results')
  },

  stopLoadingSpinner () { this.ui.loader.html('') }
})
