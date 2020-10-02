// A set of functions to display a list of suggestions and the the view be informed of
// the selected suggestion via onAutoCompleteSelect and onAutoCompleteUnselect hooks

// Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.behavior.js

import getActionKey from 'lib/get_action_key'

import Suggestions from 'modules/entities/collections/suggestions'
import AutocompleteSuggestions from '../autocomplete_suggestions'
import properties from 'modules/entities/lib/properties'

import {
  addDefaultSuggestionsUris,
  addNextDefaultSuggestionsBatch,
  showDefaultSuggestions,
} from './suggestions/default_suggestions'

import { search, loadMoreFromSearch } from './suggestions/search_suggestions'

export default {
  onRender () {
    if (this.suggestions == null) initializeAutocomplete.call(this)
    this.suggestionsRegion.show(new AutocompleteSuggestions({ collection: this.suggestions }))
    return addDefaultSuggestionsUris.call(this)
  },

  onKeyDown (e) {
    const key = getActionKey(e)
    // only addressing 'tab' as it isn't caught by the keyup event
    if (key === 'tab') {
      // In the case the dropdown was shown and a value was selected
      // @fillQuery will have been triggered, the input filled
      // and the selected suggestion kept at end: we can let the event
      // propagate to move to the next input
      return this.hideDropdown()
    }
  },

  onKeyUp (e) {
    e.preventDefault()
    e.stopPropagation()

    const value = this.ui.input.val()
    const actionKey = getActionKey(e)

    updateOnKey.call(this, value, actionKey)
    this._lastValue = value
  },

  showDropdown () {
    this.suggestionsRegion.$el.show()
  },

  hideDropdown () {
    this.suggestionsRegion.$el.hide()
    this.ui.input.focus()
  },

  showLoadingSpinner (toggleResults = true) {
    this.suggestionsRegion.currentView.showLoadingSpinner()
    if (toggleResults) this.$el.find('.results').hide()
  },

  stopLoadingSpinner (toggleResults = true) {
    this.suggestionsRegion.currentView.stopLoadingSpinner()
    if (toggleResults) this.$el.find('.results').show()
  }
}

const initializeAutocomplete = function () {
  const property = this.options.model.get('property');
  ({ searchType: this.searchType } = properties[property])
  this.suggestions = new Suggestions([], { property })
  this.lazySearch = _.debounce(search.bind(this), 400)

  this.listenTo(this.suggestions, 'selected:value', completeQuery.bind(this))
  this.listenTo(this.suggestions, 'highlight', fillQuery.bind(this))
  this.listenTo(this.suggestions, 'error', showAlertBox.bind(this))
  this.listenTo(this.suggestions, 'load:more', loadMore.bind(this))
}

// Complete the query using the selected suggestion.
const completeQuery = function (suggestion) {
  fillQuery.call(this, suggestion)
  return this.hideDropdown()
}

// Complete the query using the highlighted or the clicked suggestion.
const fillQuery = function (suggestion) {
  this.ui.input.val(suggestion.get('label'))
  this.onAutoCompleteSelect(suggestion)
}

const loadMore = function () {
  if (this._showingDefaultSuggestions) {
    return addNextDefaultSuggestionsBatch.call(this, false)
  } else { return loadMoreFromSearch.call(this) }
}

const showAlertBox = function (err) {
  this.$el.trigger('alert', { message: err.message })
}

const updateOnKey = function (value, actionKey) {
  if (actionKey != null) {
    const actionMade = keyAction.call(this, actionKey)
    if (actionMade !== false) return
  }

  if (value.length === 0) {
    showDefaultSuggestions.call(this)
    this._showingDefaultSuggestions = true
  } else if (value !== this._lastValue) {
    this.showDropdown()
    this.lazySearch(value)
    this._showingDefaultSuggestions = false
  }
}

const keyAction = function (actionKey) {
  // Actions happening in any case
  if (actionKey === 'esc') {
    this.hideDropdown()
    return true
  }

  // Actions conditional to suggestions state
  if (!this.suggestions.isEmpty()) {
    if (actionKey === 'enter') {
      this.suggestions.trigger('select:from:key')
      return true
    } else if (actionKey === 'down') {
      this.showDropdown()
      this.suggestions.trigger('highlight:next')
      return true
    } else if (actionKey === 'up') {
      this.showDropdown()
      this.suggestions.trigger('highlight:previous')
      return true
    }
  }

  return false
}
