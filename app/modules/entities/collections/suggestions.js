// Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.collection.js

import SearchResult from '#entities/models/search_result'

export default Backbone.Collection.extend({
  initialize (data, options) {
    this.lastInput = null

    this.index = -1

    this.on('highlight:next', this.highlightNext)
    this.on('highlight:previous', this.highlightPrevious)
    this.on('highlight:first', this.highlightFirst)
    this.on('highlight:last', this.highlightLast)
    this.on('select:from:key', this.selectFromKey)
    this.on('select:from:click', this.selectFromClick)
  },

  model: SearchResult,

  // Select first suggestion unless the suggestion list
  // has been navigated then select at the current index.
  selectFromKey () {
    const index = this.isStarted() ? this.index : 0
    this.trigger('selected:value', this.at(index))
  },

  selectFromClick (model) {
    this.index = this.models.indexOf(model)
    this.trigger('selected:value', model)
  },

  highlightPrevious () {
    if (!this.isFirst()) this.highlightAt(this.index - 1)
  },
  highlightNext () {
    if (!this.isLast()) this.highlightAt(this.index + 1)
  },
  highlightFirst () {
    this.highlightAt(0)
  },
  highlightLast () {
    this.highlightAt(this.length - 1)
  },
  highlightAt (index) {
    if (this.index === index) return

    if (this.isStarted()) this.removeHighlight(this.index)
    this.index = index
    this.highlight(index)
  },

  isFirst () {
    return this.index === 0
  },
  isLast () {
    return this.index === (this.length - 1)
  },

  // Check to see if we have navigated through the
  // suggestions list yet.
  isStarted () {
    return this.index !== -1
  },

  highlight (index) {
    this.highlightEvent('highlight', index)
  },
  removeHighlight (index) {
    this.highlightEvent('highlight:remove', index)
  },
  highlightEvent (eventName, index) {
    const model = this.at(index)
    // Known case: the collection just got reset
    if (model == null) return
    model.trigger(eventName, model)
    // events required by modules/entities/views/editor/lib/autocomplete.js
    this.trigger(eventName, model)
  }
})
