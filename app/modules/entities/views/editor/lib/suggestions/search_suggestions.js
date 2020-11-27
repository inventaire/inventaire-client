import typeSearch from 'modules/entities/lib/search/type_search'
import forms_ from 'modules/general/lib/forms'
const batchLength = 10

const search = function (searchValue) {
  // remove the value passed to the view as the searchValue changed
  removeCurrentViewValue.call(this)

  searchValue = searchValue.trim().replace(/\s{2,}/g, ' ')
  if (searchValue === this.lastSearchValue) return Promise.resolve()

  this.showLoadingSpinner()

  this.suggestions.index = -1
  this.lastSearchValue = searchValue
  this._searchOffset = 0

  return _search.call(this, searchValue)
  .then(results => {
    if ((results != null) && (results.length === 0)) {
      this._lastResultsLength = results.length
      this.suggestionsRegion.currentView.$el.addClass('no-results')
    } else {
      this.suggestionsRegion.currentView.$el.removeClass('no-results')
    }
    this.suggestions.reset(results)
    return this.stopLoadingSpinner()
  })
  .catch(err => {
    this.hideDropdown()
    return forms_.catchAlert(this, err)
  })
}

const _search = function (searchValue) {
  return typeSearch(this.searchType, searchValue, batchLength, this._searchOffset)
  .then(results => {
    // Ignore the results if the searchValue changed
    if (searchValue !== this.lastSearchValue) return
    return results
  })
}

const removeCurrentViewValue = function () { this.onAutoCompleteUnselect() }

const loadMoreFromSearch = function () {
  // Do not try to fetch more results if the last batch was incomplete or does not exist
  if (!this._lastResultsLength || this._lastResultsLength < batchLength) return this.stopLoadingSpinner()

  this.showLoadingSpinner(false)
  this._searchOffset += batchLength
  return _search.call(this, this.lastSearchValue)
  .then(results => {
    const currentResultsUri = this.suggestions.map(model => model.get('uri'))
    const newResults = results.filter(result => !currentResultsUri.includes(result.uri))
    this._lastResultsLength = newResults.length
    if (newResults.length > 0) this.suggestions.add(newResults)
    return this.stopLoadingSpinner(false)
  })
  .catch(forms_.catchAlert.bind(null, this))
}

export { search, loadMoreFromSearch }
