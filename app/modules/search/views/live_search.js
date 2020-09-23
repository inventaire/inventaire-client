// TODO:
// - hint to input ISBNs directly, maybe in the alternatives sections
// - add 'help': indexed wiki.inventaire.io entries to give results
//   to searches such as 'FAQ' or 'help creating group'
// - add 'place': search Wikidata for entities with coordinates (wdt:P625)
//   and display a layout with users & groups nearby, as well as books with
//   narrative location (wdt:P840), or authors born (wdt:P19)
//   or dead (wdt:P20) nearby

const Results = Backbone.Collection.extend({ model: require('../models/result') });
const wikidataSearch = require('modules/entities/lib/search/wikidata_search')(false);
const findUri = require('../lib/find_uri');
const error_ = require('lib/error');
const { looksLikeAnIsbn, normalizeIsbn } = require('lib/isbn');
const screen_ = require('lib/screen');
const searchBatchLength = 10;
let searchCount = 0;

export default Marionette.CompositeView.extend({
  id: 'live-search',
  template: require('./templates/live_search'),
  childViewContainer: 'ul.results',
  childView: require('./result'),
  emptyView: require('./no_result'),

  initialize() {
    this.collection = new Results;
    this._lazySearch = _.debounce(this.search.bind(this), 500);
    ({ section: this.selectedSectionName } = this.options);
    return this._searchOffset = 0;
  },

  ui: {
    all: '#section-all',
    sections: '.searchSection',
    resultsWrapper: '.resultsWrapper',
    results: 'ul.results',
    alternatives: '.alternatives',
    shortcuts: '.shortcuts',
    loader: '.loaderWrapper'
  },

  serializeData() {
    const sections = sectionsData();
    if (sections[this.selectedSectionName] == null) {
      _.warn({ sections, selectedSectionName: this.selectedSectionName }, 'unknown search section');
      this.selectedSectionName = 'all';
    }
    sections[this.selectedSectionName].selected = true;
    return { sections };
  },

  events: {
    'click .searchSection': 'updateSections',
    'click .createEntity': 'showEntityCreate'
  },

  onShow() {
    // Doesn't work if set in events for some reason
    return this.ui.resultsWrapper.on('scroll', this.onResultsScroll.bind(this));
  },

  onSpecialKey(key){
    switch (key) {
      case 'up': return this.highlightPrevious();
      case 'down': return this.highlightNext();
      case 'enter': return this.showCurrentlyHighlightedResult();
      case 'pageup': return this.selectPrevSection();
      case 'pagedown': return this.selectNextSection();
      default: return;
    }
  },

  updateSections(e){ return this.selectTypeFromTarget($(e.currentTarget)); },

  selectPrevSection() { return this.selectByPosition('prev', 'last'); },
  selectNextSection() { return this.selectByPosition('next', 'first'); },
  selectByPosition(relation, fallback){
    let $target = this.$el.find('.selected')[relation]();
    if ($target.length === 0) { $target = this.$el.find('.sections a')[fallback](); }
    return this.selectTypeFromTarget($target);
  },

  selectTypeFromTarget($target){
    const { id } = $target[0];
    const type = getTypeFromId(id);
    return this.selectType(type);
  },

  selectType(type){
    if (type === this._lastType) { return; }

    this.ui.sections.removeClass('selected');
    this.ui.sections.filter(`#section-${type}`).addClass('selected');
    if (type === 'all') { this.section = null;
    } else { this.section = child => child.get('typeAlias') === type; }

    this._searchOffset = 0;
    this._lastType = type;
    // Refresh the search with the new sections
    if ((this._lastSearch != null) && (this._lastSearch !== '')) { this.lazySearch(this._lastSearch); }

    return this.updateAlternatives(type);
  },

  updateAlternatives(search){
    if (sectionsWithAlternatives.includes(this._lastType)) { return this.showAlternatives(search);
    } else { return this.hideAlternatives(); }
  },

  search(search){
    search = search?.trim();
    this._lastSearch = search;
    this._lastSearchId = ++searchCount;
    this._searchOffset = 0;

    if (!_.isNonEmptyString(search)) { return this.hideAlternatives(); }

    const uri = findUri(search);
    if (uri != null) { return this.getResultFromUri(uri, this._lastSearchId, this._lastSearch); }

    this._search(search)
    .then(this.resetResults.bind(this, this._lastSearchId));

    this._waitingForAlternatives = true;
    return this.setTimeout(this.updateAlternatives.bind(this, search), 2000);
  },

  _search(search){
    const types = this.getTypes();
    // Subjects aren't indexed in the server ElasticSearch
    // as it's not a subset of Wikidata anymore: pretty much anything
    // on Wikidata can be considered a subject
    if (types === 'subjects') {
      return wikidataSearch(search, searchBatchLength, this._searchOffset)
      .map(formatSubject);
    } else {
      // Increasing search limit instead of offset, as search pages aren't stable:
      // results popularity might have change the results order between two requests,
      // thus the need to re-fetch from offset 0 but increasing the page length, and adding only
      // the results that weren't returned in the previous query, whatever there place
      // in the newly returned results
      const searchLimit = searchBatchLength + this._searchOffset;
      return _.preq.get(app.API.search(types, search, searchLimit))
      .get('results');
    }
  },

  lazySearch(search){
    if (search.length > 0) { this.showLoadingSpinner();
    } else { this.stopLoadingSpinner(); }
    // Hide previous results to limit confusion and scroll up
    this.resetResults();
    return this._lazySearch(search);
  },

  showAlternatives(search){
    if (!_.isNonEmptyString(search)) { return; }
    if (search !== this._lastSearch) { return; }
    if (!this._waitingForAlternatives) { return; }

    this.ui.alternatives.addClass('shown');
    return this._waitingForAlternatives = false;
  },

  hideAlternatives() {
    this._waitingForAlternatives = false;
    return this.ui.alternatives.removeClass('shown');
  },

  showShortcuts() { return this.ui.shortcuts.addClass('shown'); },

  getResultFromUri(uri, searchId, rawSearch){
    _.log(uri, 'uri found');
    this.showLoadingSpinner();

    return app.request('get:entity:model', uri)
    .then(entity=> this.resetResults(searchId, [ formatEntity(entity) ]))
    .catch(err=> {
      if (err.message === 'entity_not_found') {
        this._waitingForAlternatives = true;
        return this.showAlternatives(rawSearch);
      } else {
        throw err;
      }
  }).finally(this.stopLoadingSpinner.bind(this));
  },

  showLoadingSpinner() {
    this.ui.loader.html('<div class="small-loader"></div>');
    return this.$el.removeClass('no-results');
  },

  stopLoadingSpinner() { return this.ui.loader.html(''); },

  getTypes() {
    const name = getTypeFromId(this.$el.find('.selected')[0].id);
    return sectionToTypes[name];
  },

  resetResults(searchId, results){
    // Ignore results from any search that isn't the latest search
    if ((searchId != null) && (searchId !== this._lastSearchId)) { return; }

    this.resetHighlightIndex();

    if (results != null) {
      this.stopLoadingSpinner();
      this._lastResultsLength = results.length;

      // Track TypeErrors where Result model 'initialize' crashes
      try { this.collection.reset(results); }
      catch (err) {
        if (err.context == null) { err.context = {}; }
        err.context.results = results;
        throw err;
      }

    } else {
      this.collection.reset();
    }

    if ((results != null) && (results.length === 0)) {
      return this.$el.addClass('no-results');
    } else {
      this.$el.removeClass('no-results');
      return this.setTimeout(this.showShortcuts.bind(this), 1000);
    }
  },

  highlightNext() { return this.highlightIndexChange(1); },
  highlightPrevious() { return this.highlightIndexChange(-1); },
  highlightIndexChange(incrementor){
    if (this._currentHighlightIndex == null) { this._currentHighlightIndex = -1; }
    const newIndex = this._currentHighlightIndex + incrementor;
    const previousView = this.children.findByIndex(this._currentHighlightIndex);
    const view = this.children.findByIndex(newIndex);
    if (view != null) {
      previousView?.unhighlight();
      view.highlight();
      this._currentHighlightIndex = newIndex;

      return screen_.innerScrollTop(this.ui.results, view?.$el);
    }
  },

  showCurrentlyHighlightedResult() {
    const hilightedView = this.children.findByIndex(this._currentHighlightIndex);
    if (hilightedView) { return hilightedView.showResult(); }
  },

  resetHighlightIndex() {
    this.$el.find('.highlight').removeClass('highlight');
    return this._currentHighlightIndex = -1;
  },

  showEntityCreate() {
    this.triggerMethod('hide:live:search');
    if (looksLikeAnIsbn(this._lastSearch)) {
      // If the edition entity for this ISBN really doesn't exist
      // it will redirect to the ISBN edition creation form
      return app.execute('show:entity', this._lastSearch);
    } else {
      const section = this._lastType || this.selectedSectionName;
      const type = sectionToTypes[section];
      return app.execute('show:entity:create', { label: this._lastSearch, type, allowToChangeType: true });
    }
  },

  onResultsScroll(e){
    const visibleHeight = this.ui.resultsWrapper.height();
    const { scrollHeight, scrollTop } = e.currentTarget;
    const scrollBottom = scrollTop + visibleHeight;
    if (scrollBottom === scrollHeight) { return this.loadMore(); }
  },

  loadMore() {
    // Do not try to fetch more results if the last batch was incomplete
    if (this._lastResultsLength < searchBatchLength) { return this.stopLoadingSpinner(); }

    this.showLoadingSpinner();
    this._searchOffset += searchBatchLength;
    return this._search(this._lastSearch)
    .then(this.addNewResults.bind(this));
  },

  addNewResults(results){
    const currentResultsUri = this.collection.map(model => model.get('uri'));
    const newResults = results.filter(result => !currentResultsUri.includes(result.uri));
    this._lastResultsLength = newResults.length;
    return this.collection.add(newResults);
  }
});

var sectionToTypes = {
  all: [ 'works', 'humans', 'series', 'publishers', 'collections', 'users', 'groups' ],
  book: 'works',
  author: 'humans',
  serie: 'series',
  collection: 'collections',
  publisher: 'publishers',
  subject: 'subjects',
  user: 'users',
  group: 'groups'
};

var sectionsWithAlternatives = [ 'all', 'book', 'author', 'serie', 'collection', 'publisher' ];

var getTypeFromId = id => id.replace('section-', '');

// Pre-formatting is required to set the type
// Taking the opportunity to omit all non-required data
var formatSubject = result => ({
  id: result.id,
  label: result.label,
  description: result.description,
  uri: `wd:${result.id}`,
  type: 'subjects'
});

var formatEntity = function(entity){
  if (entity?.toJSON == null) {
    error_.report('cant format invalid entity', { entity });
    return;
  }

  const data = entity.toJSON();
  data.image = data.image?.url;
  // Return a model to prevent having it re-formatted
  // as a Result model, which works from a result object, not an entity
  return new Backbone.Model(data);
};

var sectionsData = () => ({
  all: { label: 'all' },
  book: { label: 'book' },
  author: { label: 'author' },
  serie: { label: 'series_singular' },
  user: { label: 'user' },
  group: { label: 'group' },
  publisher: { label: 'publisher' },
  collection: { label: 'collection' },
  subject: { label: 'subject' }
});
