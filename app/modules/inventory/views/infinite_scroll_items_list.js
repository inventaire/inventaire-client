import { startLoading, stopLoading } from 'modules/general/plugins/behaviors'
import { wait } from 'lib/promises'
import Loading from 'behaviors/loading'

const alwaysFalse = () => false

export default Marionette.CollectionView.extend({
  behaviors: {
    Loading,
  },

  events: {
    'inview .fetchMore': 'infiniteScroll'
  },

  initInfiniteScroll () {
    ({ hasMore: this.hasMore, fetchMore: this.fetchMore } = this.options)
    if (!this.hasMore) this.hasMore = alwaysFalse
    this._fetching = false
  },

  async infiniteScroll () {
    if (this._fetching || !this.hasMore()) return
    this._fetching = true
    this.startLoading()

    return this.fetchMore()
    .then(this.stopLoading.bind(this))
    // Give the time for the DOM to update
    .then(() => wait(200))
    .finally(() => { this._fetching = false })
  },

  startLoading () { startLoading.call(this, '.fetchMore') },
  stopLoading () { stopLoading.call(this, '.fetchMore') }
})
