import typeSearch from 'modules/entities/lib/search/type_search'
import forms_ from 'modules/general/lib/forms'
const batchLength = 10

const search = function (input) {
  // remove the value passed to the view as the input changed
  removeCurrentViewValue.call(this)

  input = input.trim().replace(/\s{2,}/g, ' ')
  if (input === this.lastInput) { return Promise.resolve() }

  this.showLoadingSpinner()

  this.suggestions.index = -1
  this.lastInput = input
  this._searchOffset = 0

  return _search.call(this, input)
  .then(results => {
    if ((results != null) && (results.length === 0)) {
      this._lastResultsLength = results.length
      this.suggestionsRegion.currentView.$el.addClass('no-results')
    } else {
      this.suggestionsRegion.currentView.$el.removeClass('no-results')
    }
    this.suggestions.reset(results)
    return this.stopLoadingSpinner()
  }).catch(err => {
    this.hideDropdown()
    return forms_.catchAlert(this, err)
  })
}

var _search = function (input) {
  return typeSearch(this.searchType, input, batchLength, this._searchOffset)
  .then(results => {
    // Ignore the results if the input changed
    if (input !== this.lastInput) { return }
    return results
  })
}

var removeCurrentViewValue = function () { return this.onAutoCompleteUnselect() }

const loadMoreFromSearch = function () {
  // Do not try to fetch more results if the last batch was incomplete
  if (this._lastResultsLength < batchLength) { return this.stopLoadingSpinner() }

  this.showLoadingSpinner(false)
  this._searchOffset += batchLength
  return _search.call(this, this.lastInput)
  .then(results => {
    const currentResultsUri = this.suggestions.map(model => model.get('uri'))
    const newResults = results.filter(result => !currentResultsUri.includes(result.uri))
    this._lastResultsLength = newResults.length
    if (newResults.length > 0) { this.suggestions.add(newResults) }
    return this.stopLoadingSpinner(false)
  }).catch(forms_.catchAlert.bind(null, this))
}

export { search, loadMoreFromSearch }
