import preq from 'lib/preq'
import behaviorsPlugin from 'modules/general/plugins/behaviors'

export default Marionette.CompositeView.extend({
  id: 'changeLayout',
  template: require('./templates/changes_layout'),
  childViewContainer: '#feed',
  childView: require('./feed_li'),
  initialize () {
    this.collection = new Backbone.Collection()
    this.fetchingMore = true

    return fetchChanges()
    .then(this.parseResponse.bind(this))
  },

  behaviors: {
    Loading: {}
  },

  ui: {
    counter: '.counter'
  },

  events: {
    'inview .more': 'showMoreUnlessAlreadyFetching'
  },

  parseResponse (uris) {
    this.rest = uris
    this.showMore()
  },

  showMore (batchLength = 10) {
    this.fetchingMore = true
    // Don't fetch more and keep fetchingMore to true to prevent further requests
    if (this.rest.length === 0) return
    behaviorsPlugin.startLoading.call(this, '.more')
    const batch = this.rest.slice(0, batchLength)
    this.rest = this.rest.slice(batchLength)
    return this.addFromUris(batch)
  },

  showMoreUnlessAlreadyFetching () {
    if (!this.fetchingMore) this.showMore()
  },

  addFromUris (uris) {
    return app.request('get:entities:models', { uris })
    .then(this.collection.add.bind(this.collection))
    .then(this.doneFetching.bind(this))
  },

  doneFetching () {
    this.fetchingMore = false
    behaviorsPlugin.stopLoading.call(this)
    this.ui.counter.html(this.collection.length)
  }
})

const fetchChanges = () => preq.get(app.API.entities.changes)
.get('uris')
