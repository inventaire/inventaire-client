typeSearch = require 'modules/entities/lib/search/type_search'
forms_ = require 'modules/general/lib/forms'
batchLength = 10

search = (input)->
  @showLoadingSpinner()
  # remove the value passed to the view as the input changed
  removeCurrentViewValue.call @

  input = input.trim().replace /\s{2,}/g, ' '
  if input is @lastInput then return Promise.resolve()

  @suggestions.index = -1
  @lastInput = input
  @_searchOffset = 0

  _search.call @, input
  .then (results)=>
    @_lastResultsLength = results.length
    if results? and results.length is 0
      @suggestionsRegion.currentView.$el.addClass 'no-results'
    else
      @suggestionsRegion.currentView.$el.removeClass 'no-results'
    @suggestions.reset results
    @stopLoadingSpinner()
  .catch (err)=>
    @hideDropdown()
    forms_.catchAlert @, err

_search = (input)->
  typeSearch @searchType, input, batchLength, @_searchOffset
  .then (results)=>
    # Ignore the results if the input changed
    if input isnt @lastInput then return
    return results

removeCurrentViewValue = -> @onAutoCompleteUnselect()

loadMoreFromSearch = ->
  # Do not try to fetch more results if the last batch was incomplete
  if @_lastResultsLength < batchLength then return @stopLoadingSpinner()

  @showLoadingSpinner false
  @_searchOffset += batchLength
  _search.call @, @lastInput
  .then (results)=>
    currentResultsUri = @suggestions.map (model)-> model.get('uri')
    newResults = results.filter (result)-> result.uri not in currentResultsUri
    @_lastResultsLength = newResults.length
    if newResults.length > 0 then @suggestions.add newResults
    @stopLoadingSpinner false
  .catch forms_.catchAlert.bind(null, @)

module.exports = { search, loadMoreFromSearch }
