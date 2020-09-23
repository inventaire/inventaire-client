export default Marionette.Behavior.extend({
  ui: {
    extract: '.extract',
    togglers: '.toggler i'
  },

  events: {
    'click .toggler': 'toggleExtractLength'
  },

  toggleExtractLength() {
    this.ui.extract.toggleClass('clamped');
    return this.ui.togglers.toggleClass('hidden');
  }
});
