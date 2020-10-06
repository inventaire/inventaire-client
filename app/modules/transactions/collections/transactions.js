import Transaction from '../models/transaction'

export default Backbone.Collection.extend({
  url () { return app.API.transactions },
  parse (res) { return res.transactions },
  model: Transaction,
  comparator (transaction) { return -transaction.get('created') }
})
