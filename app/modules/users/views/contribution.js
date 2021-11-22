import contributionTemplate from './templates/contribution.hbs'
import { isOpenedOutside } from 'lib/utils'
import PreventDefault from 'behaviors/prevent_default'

export default Marionette.View.extend({
  className: 'contribution',
  template: contributionTemplate,
  tagName: 'li',

  ui: {
    fullDetails: '.fullDetails',
    togglers: '.togglers span'
  },

  behaviors: {
    PreventDefault,
  },

  modelEvents: {
    grab: 'lazyRender'
  },

  serializeData () {
    const attrs = this.model.serializeData()
    attrs.showUser = this.options.showUser
    return attrs
  },

  events: {
    'click .handle': 'toggleFullDetails',
    'click .showUserContributions': 'showUserContributions',
  },

  toggleFullDetails (e) {
    // Prevent toggling when the intent was clicking on a link
    if (e.target.tagName === 'A') return

    this.ui.fullDetails.toggleClass('hidden')
    this.ui.togglers.toggleClass('hidden')
  },

  showUserContributions (e) {
    if (!isOpenedOutside(e)) app.execute('show:user:contributions', this.model.user)
  },
})
