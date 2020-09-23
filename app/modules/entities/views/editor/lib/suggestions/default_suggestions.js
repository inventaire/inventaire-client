const batchLength = 10;
import { prepareSearchResult } from 'modules/entities/lib/search/entities_uris_results';
import getSuggestionsPerProperties from 'modules/entities/views/editor/lib/get_suggestions_per_properties';

const addDefaultSuggestionsUris = function() {
  return getSuggestionsPerProperties(this.property, this.model)
  .then(setDefaultSuggestions.bind(this));
};

var setDefaultSuggestions = function(uris){
  if (uris == null) { return; }

  this._showingDefaultSuggestions = true;
  this._remainingDefaultSuggestionsUris = uris;
  this._defaultSuggestions = [];

  return addNextDefaultSuggestionsBatch.call(this)
  .then(() => {
    if (this._showingDefaultSuggestions) { return showDefaultSuggestions.call(this); }
  });
};

var showDefaultSuggestions = function() {
  if ((this._defaultSuggestions != null) && (this._defaultSuggestions.length > 0)) {
    this.suggestions.reset(this._defaultSuggestions);
    return this.showDropdown();
  } else {
    return this.hideDropdown();
  }
};

var addNextDefaultSuggestionsBatch = function() {
  const uris = this._remainingDefaultSuggestionsUris;
  if (uris.length === 0) { return Promise.resolve(); }

  const nextBatch = uris.slice(0, batchLength);
  this._remainingDefaultSuggestionsUris = uris.slice(batchLength);

  return app.request('get:entities:models', { uris: nextBatch })
  .map(prepareSearchResult)
  .then(results=> {
    this._defaultSuggestions.push(...Array.from(results || []));
    return this.suggestions.add(results);
  });
};

export { addDefaultSuggestionsUris, addNextDefaultSuggestionsBatch, showDefaultSuggestions };
