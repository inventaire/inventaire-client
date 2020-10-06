import autocompleteNoSuggestionTemplate from './templates/autocomplete_no_suggestion.hbs'

export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'autocomplete-no-suggestion no-suggestion',
  template: autocompleteNoSuggestionTemplate
})
