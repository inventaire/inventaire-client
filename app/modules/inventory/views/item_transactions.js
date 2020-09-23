/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.CompositeView.extend({
  className: 'itemTransactions',
  template: require('./templates/item_transactions'),
  childViewContainer: '.transactions',
  childView: require('modules/transactions/views/transaction_preview'),
  childViewOptions: {
    onItem: true
  }
})
