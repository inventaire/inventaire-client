import autocompleteSuggestionTemplate from './templates/autocomplete_suggestion.hbs'

// Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.childview.js

export default Marionette.View.extend({
  tagName: 'li',
  className: 'autocomplete-suggestion',
  template: autocompleteSuggestionTemplate,

  events: {
    'click .select': 'select'
  },

  modelEvents: {
    highlight: 'highlight',
    'highlight:remove': 'removeHighlight'
  },

  highlight () {
    this.trigger('highlight')
    this.$el.addClass('active')
  },

  removeHighlight () { this.$el.removeClass('active') },

  select () { this.triggerMethod('select:from:click', this.model) }
})
