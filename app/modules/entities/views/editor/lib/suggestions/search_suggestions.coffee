typeSearch = require 'modules/entities/lib/search/type_search'
forms_ = require 'modules/general/lib/forms'
batchLength = 10

search = (searchValue)->
  # remove the value passed to the view as the searchValue changed
  removeCurrentViewValue.call @

  searchValue = searchValue.trim().replace /\s{2,}/g, ' '
  if searchValue is @lastSearchValue then return Promise.resolve()
  @showLoadingSpinner()

  @suggestions.index = -1
  @lastSearchValue = searchValue
  @_searchOffset = 0

  _search.call @, searchValue
  .then (results)=>
    if results? and results.length is 0
      @_lastResultsLength = results.length
      @suggestionsRegion.currentView.$el.addClass 'no-results'
    else
      @suggestionsRegion.currentView.$el.removeClass 'no-results'
    @suggestions.reset results
    @stopLoadingSpinner()
  .catch (err)=>
    @hideDropdown()
    forms_.catchAlert @, err

_search = (searchValue)->
  typeSearch @searchType, searchValue, batchLength, @_searchOffset
  .then (results)=>
    # Ignore the results if the searchValue changed
    if searchValue isnt @lastSearchValue then return
    return results

removeCurrentViewValue = -> @onAutoCompleteUnselect()

loadMoreFromSearch = ->
  # Do not try to fetch more results if the last batch was incomplete
  if @_lastResultsLength < batchLength then return @stopLoadingSpinner()

  @showLoadingSpinner false
  @_searchOffset += batchLength
  _search.call @, @lastSearchValue
  .then (results)=>
    currentResultsUri = @suggestions.map (model)-> model.get('uri')
    newResults = results.filter (result)-> result.uri not in currentResultsUri
    @_lastResultsLength = newResults.length
    if newResults.length > 0 then @suggestions.add newResults
    @stopLoadingSpinner false
  .catch forms_.catchAlert.bind(null, @)

module.exports = { search, loadMoreFromSearch }
