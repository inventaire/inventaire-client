/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Backbone.Collection.extend({
  url () { return app.API.transactions },
  parse (res) { return res.transactions },
  model: require('../models/transaction'),
  comparator (transaction) { return -transaction.get('created') }
})
