// Forked from: https://github.com/KyleNeedham/autocomplete/blob/master/src/autocomplete.childview.coffee

export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'autocomplete-suggestion',
  template: require('./templates/autocomplete_suggestion'),

  events: {
    'click .select': 'select'
  },

  modelEvents: {
    'highlight': 'highlight',
    'highlight:remove': 'removeHighlight'
  },

  highlight() {
    this.trigger('highlight');
    return this.$el.addClass('active');
  },

  removeHighlight() { return this.$el.removeClass('active'); },

  select() { return this.triggerMethod('select:from:click', this.model); }
});
