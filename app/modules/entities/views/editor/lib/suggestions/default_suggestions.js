import { prepareSearchResult } from '#modules/entities/lib/search/entities_uris_results'
import getSuggestionsPerProperties from '#modules/entities/views/editor/lib/get_suggestions_per_properties'
const batchLength = 10

const addDefaultSuggestionsUris = function () {
  return getSuggestionsPerProperties(this.property, this.model)
  .then(setDefaultSuggestions.bind(this))
}

const setDefaultSuggestions = function (uris) {
  if (uris == null) return

  this._showingDefaultSuggestions = true
  this._remainingDefaultSuggestionsUris = uris
  this._defaultSuggestions = []

  return addNextDefaultSuggestionsBatch.call(this)
  .then(() => {
    if (this._showingDefaultSuggestions) return showDefaultSuggestions.call(this)
  })
}

const showDefaultSuggestions = function () {
  if ((this._defaultSuggestions != null) && (this._defaultSuggestions.length > 0)) {
    this.suggestions.reset(this._defaultSuggestions)
    this.showDropdown()
  } else {
    return this.hideDropdown()
  }
}

const addNextDefaultSuggestionsBatch = async function () {
  const uris = this._remainingDefaultSuggestionsUris
  if (uris.length === 0) return

  const nextBatch = uris.slice(0, batchLength)
  this._remainingDefaultSuggestionsUris = uris.slice(batchLength)

  let results = await app.request('get:entities:models', { uris: nextBatch })
  results = (results || []).map(prepareSearchResult)
  this._defaultSuggestions.push(...results)
  return this.suggestions.add(results)
}

export { addDefaultSuggestionsUris, addNextDefaultSuggestionsBatch, showDefaultSuggestions }
