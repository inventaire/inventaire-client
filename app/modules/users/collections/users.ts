import User from '../models/user.ts'

export default Backbone.Collection.extend({
  model: User,
  url () { return app.API.users.friends },

  initialize () {
    this.lazyResort = _.debounce(this.sort.bind(this), 500)
    // model events are also triggerend on parent collection
    this.on('change:highlightScore', this.lazyResort)
  },

  comparator: 'highlightScore',

  // Include cids, but that's probably still faster than doing a map on models
  allIds () { return Object.keys(app.users._byId) },
})
