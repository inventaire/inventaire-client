import behaviorsPlugin from 'modules/general/plugins/behaviors'
const alwaysFalse = () => false

export default Marionette.CompositeView.extend({
  behaviors: {
    Loading: {}
  },

  events: {
    'inview .fetchMore': 'infiniteScroll'
  },

  initInfiniteScroll () {
    ({ hasMore: this.hasMore, fetchMore: this.fetchMore } = this.options)
    if (!this.hasMore) { this.hasMore = alwaysFalse }
    return this._fetching = false
  },

  infiniteScroll () {
    if (this._fetching || !this.hasMore()) { return }
    this._fetching = true
    this.startLoading()

    return this.fetchMore()
    .then(this.stopLoading.bind(this))
    // Give the time for the DOM to update
    .delay(200)
    .finally(() => { return this._fetching = false })
  },

  startLoading () { return behaviorsPlugin.startLoading.call(this, '.fetchMore') },
  stopLoading () { return behaviorsPlugin.stopLoading.call(this, '.fetchMore') }
})
