export default Marionette.Behavior.extend({
  ui: {
    extract: '.extract',
    togglerButton: '.toggler',
    togglers: '.toggler i',
  },

  events: {
    'click .toggler': 'toggleExtractLength'
  },

  toggleExtractLength () {
    this.ui.extract.toggleClass('clamped')
    const expanded = this.ui.togglerButton.attr('aria-expanded') === 'true'
    this.ui.togglerButton.attr('aria-expanded', !expanded)
    this.ui.togglers.toggleClass('hidden')
  }
})
