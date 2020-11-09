import userContributionTemplate from './templates/user_contribution.hbs'

export default Marionette.ItemView.extend({
  className: 'userContribution',
  template: userContributionTemplate,
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
    if (e.target.tagName === 'A') return

    this.ui.operations.toggleClass('hidden')
    this.ui.togglers.toggleClass('hidden')
  }
})
