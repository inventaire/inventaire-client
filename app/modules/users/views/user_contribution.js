export default Marionette.ItemView.extend({
  className: 'userContribution',
  template: require('./templates/user_contribution'),
  tagName: 'li',

  ui: {
    operations: '.operations',
    togglers: '.togglers span'
  },

  modelEvents: {
    grab: 'lazyRender'
  },

  serializeData () { return this.model.serializeData() },

  events: {
    'click .header': 'toggleOperations'
  },

  toggleOperations (e) {
    // Prevent toggling when the intent was clicking on a link
    if (e.target.tagName === 'A') { return }

    this.ui.operations.toggleClass('hidden')
    return this.ui.togglers.toggleClass('hidden')
  }
})
