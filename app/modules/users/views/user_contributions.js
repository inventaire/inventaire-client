import preq from 'lib/preq'
import UserContribution from './user_contribution'
// A layout to display a list of the user data contributions

import Patches from 'modules/entities/collections/patches'

export default Marionette.CompositeView.extend({
  className: 'userContributions',
  template: require('./templates/user_contributions.hbs'),
  childViewContainer: '.contributions',
  childView: UserContribution,
  initialize () {
    ({ user: this.user } = this.options)
    this.userId = this.user.get('_id')

    this.collection = new Patches()
    this.limit = 50
    this.offset = 0

    return this.fetchMore()
  },

  ui: {
    fetchMore: '.fetchMore',
    totalContributions: '.totalContributions',
    remaining: '.remaining'
  },

  serializeData () {
    return { user: this.user.serializeData() }
  },

  fetchMore () {
    return preq.get(app.API.entities.contributions(this.userId, this.limit, this.offset))
    .then(this.parseResponse.bind(this))
  },

  parseResponse (res) {
    let patches, total;
    ({ patches, continue: this.offset, total } = res)

    if (total !== this.total) {
      this.total = total
      // Update manually instead of re-rendering as it would require to re-render
      // all the sub viewstotal
      this.ui.totalContributions.text(total)
    }

    if (this.offset != null) {
      this.ui.remaining.text(total - this.offset)
    } else { this.ui.fetchMore.hide() }

    return this.collection.add(patches)
  },

  events: {
    'click .fetchMore': 'fetchMore'
  }
})
