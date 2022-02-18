import autocompleteSuggestionsTemplate from './templates/autocomplete_suggestions.hbs'

// Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.collectionview.js

import AutocompleteSuggestion from './autocomplete_suggestion.js'
import AutocompleteNoSuggestion from './autocomplete_no_suggestion.js'

// keep in sync with app/modules/general/scss/_autocomplete.scss
const listHeight = 170

export default Marionette.CollectionView.extend({
  template: autocompleteSuggestionsTemplate,
  className: 'autocomplete-suggestions',
  childViewContainer: '.results',
  childView: AutocompleteSuggestion,
  emptyView: AutocompleteNoSuggestion,
  ui: {
    resultsWrapper: '.resultsWrapper',
    results: '.results',
    loader: '.loaderWrapper'
  },

  childViewEvents: {
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
  selectFromClick (model) {
    this.collection.trigger('select:from:click', model)
  },

  onRender () {
    // Doesn't work if set in events for some reason
    this.ui.resultsWrapper.on('scroll', this.onResultsScroll.bind(this))
  },

  onResultsScroll (e) {
    const visibleHeight = this.ui.resultsWrapper.height()
    const { scrollHeight, scrollTop } = e.currentTarget
    const scrollBottom = scrollTop + visibleHeight
    if (scrollBottom === scrollHeight) return this.loadMore()
  },

  loadMore () {
    this.collection.trigger('load:more')
  },

  showLoadingSpinner () {
    this.ui.loader.html('<div class="small-loader"></div>')
    this.$el.removeClass('no-results')
  },

  stopLoadingSpinner () { this.ui.loader.html('') }
})
