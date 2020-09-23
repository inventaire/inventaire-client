export default Backbone.Collection.extend({
  url () { return app.API.transactions },
  parse (res) { return res.transactions },
  model: require('../models/transaction'),
  comparator (transaction) { return -transaction.get('created') }
})
