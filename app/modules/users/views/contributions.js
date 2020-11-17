// A layout to display a list of the patches, aka contributions

import preq from 'lib/preq'
import Contribution from './contribution'
import Patches from 'modules/entities/collections/patches'
import contributionsTemplate from './templates/contributions.hbs'
import '../scss/contributions.scss'

export default Marionette.CompositeView.extend({
  id: 'contributions',
  template: contributionsTemplate,
  childViewContainer: '.contributions',
  childView: Contribution,
  childViewOptions () {
    return {
      showUser: this.options.user == null
    }
  },

  initialize () {
    this.user = this.options.user
    if (this.user != null) {
      this.userId = this.user.get('_id')
    } else {
      this.fetchUsers = true
    }

    this.collection = new Patches()
    this.limit = 5
    this.offset = 0

    this.fetchMore()
  },

  ui: {
    fetchMore: '.fetchMore',
    totalContributions: '.totalContributions',
    remaining: '.remaining'
  },

  serializeData () {
    return { user: this.user?.serializeData() }
  },

  fetchMore () {
    return preq.get(app.API.entities.contributions(this.userId, this.limit, this.offset))
    .then(this.parseResponse.bind(this))
  },

  async parseResponse ({ patches, continue: offset, total }) {
    this.offset = offset

    if (total !== this.total) {
      this.total = total
      // Update manually instead of re-rendering as it would require to re-render
      // all the sub viewstotal
      this.ui.totalContributions.text(total)
    }

    if (this.offset != null) {
      this.ui.remaining.text(total - this.offset)
    } else {
      this.ui.fetchMore.hide()
    }

    this.collection.add(patches)
  },

  events: {
    'click .fetchMore': 'fetchMore'
  }
})
