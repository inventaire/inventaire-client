import Transaction from '../models/transaction.js'

export default Backbone.Collection.extend({
  url () { return app.API.transactions.base },
  parse (res) { return res.transactions },
  model: Transaction,
  comparator (transaction) { return -transaction.get('created') }
})
