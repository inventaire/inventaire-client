export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'autocomplete-no-suggestion no-suggestion',
  template: require('./templates/autocomplete_no_suggestion')
});
