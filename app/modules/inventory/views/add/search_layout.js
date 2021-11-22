import PreviousSearch from './previous_search'
import searchTemplate from './templates/search_layout.hbs'
import 'modules/inventory/scss/search_layout.scss'
import PreventDefault from 'behaviors/prevent_default'
import AutoFocus from 'behaviors/auto_focus'

export default Marionette.CollectionView.extend({
  id: 'addSearchLayout',
  template: searchTemplate,
  behaviors: {
    PreventDefault,
    AutoFocus,
  },

  childViewContainer: '#history',
  childView: PreviousSearch,

  ui: {
    history: '#historyWrapper'
  },

  initialize () {
    this.collection = app.searchResultsHistory
    // re-sorting as some timestamps might have be updated
    // since the initial sorting
    this.collection.sort()
  },

  onRender () {
    if (this.collection.length > 0) {
      this.ui.history.show()
    } else {
      this.listenToHistory()
    }
  },

  events: {
    'click .clearHistory': 'clearHistory',
    'click .search-button': 'showTypeSearch'
  },

  showTypeSearch (e) {
    const type = e.currentTarget.href.split('type=')[1]
    app.execute('search:global', '', type)
  },

  clearHistory () {
    this.collection.reset()
    this.ui.history.hide()
    this.listenToHistory()
  },

  listenToHistory () {
    this.listenToOnce(this.collection, 'add', this.ui.history.show.bind(this.ui.history))
  }
})
