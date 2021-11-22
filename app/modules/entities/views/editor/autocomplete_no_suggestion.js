import autocompleteNoSuggestionTemplate from './templates/autocomplete_no_suggestion.hbs'

export default Marionette.View.extend({
  tagName: 'li',
  className: 'autocomplete-no-suggestion no-suggestion',
  template: autocompleteNoSuggestionTemplate
})
