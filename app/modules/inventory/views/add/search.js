export default Marionette.CompositeView.extend({
  id: 'addSearch',
  template: require('./templates/search'),
  behaviors: {
    PreventDefault: {},
    AutoFocus: {}
  },

  childViewContainer: '#history',
  childView: require('./previous_search'),

  ui: {
    history: '#historyWrapper'
  },

  initialize() {
    this.collection = app.searchResultsHistory;
    // re-sorting as some timestamps might have be updated
    // since the initial sorting
    return this.collection.sort();
  },

  onShow() {
    if (this.collection.length > 0) { return this.ui.history.show();
    } else { return this.listenToHistory(); }
  },

  events: {
    'click .clearHistory': 'clearHistory',
    'click .search-button': 'showTypeSearch'
  },

  showTypeSearch(e){
    const type = e.currentTarget.href.split('type=')[1];
    return app.execute('search:global', '', type);
  },

  clearHistory() {
    this.collection.reset();
    this.ui.history.hide();
    return this.listenToHistory();
  },

  listenToHistory() {
    return this.listenToOnce(this.collection, 'add', this.ui.history.show.bind(this.ui.history));
  }
});
