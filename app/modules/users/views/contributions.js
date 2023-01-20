// A layout to display a list of the patches, aka contributions

import preq from '#lib/preq'
import Contribution from './contribution.js'
import Patches from '#entities/collections/patches'
import contributionsTemplate from './templates/contributions.hbs'
import '../scss/contributions.scss'
import { startLoading, stopLoading } from '#general/plugins/behaviors'
import Loading from '#behaviors/loading'

export default Marionette.CollectionView.extend({
  id: 'contributions',
  template: contributionsTemplate,
  childViewContainer: '.contributionsList',
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
    this.limit = 10
    this.offset = 0

    this.fetchMore()
  },

  ui: {
    fetchMore: '.fetchMore',
    total: '.total',
  },

  behaviors: {
    Loading,
  },

  events: {
    'inview .fetchMore': 'fetchMore',
    'click .showUser': 'showUser',
    'click .removeFilter': 'removeFilter',
  },

  serializeData () {
    return {
      user: this.user?.serializeData(),
      filter: this.options.filter,
    }
  },

  async fetchMore () {
    if (this._fetching || this.hasMore === false) return
    this._fetching = true
    startLoading.call(this)
    this.limit = Math.min(this.limit * 2, 500)
    const res = await preq.get(app.API.entities.contributions({
      userId: this.userId,
      limit: this.limit,
      offset: this.offset,
      filter: this.options.filter,
    }))
    this.parseResponse(res)
    stopLoading.call(this)
    this._fetching = false
  },

  async parseResponse ({ patches, continue: continu, total }) {
    this.hasMore = continu != null
    this.offset = continu
    if (total !== this.total) {
      this.total = total
      // Update manually instead of re-rendering as it would require to re-render
      // all the sub viewstotal
      this.ui.total.text(total)
    }
    this.collection.add(patches)
  },

  showUser () {
    app.execute('show:user', this.user.get('_id'))
  },

  removeFilter (e) {
    app.execute('show:user:contributions', this.user)
    app.execute('querystring:remove', 'filter')
  }
})
