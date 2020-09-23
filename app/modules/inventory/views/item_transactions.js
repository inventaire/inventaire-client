export default Marionette.CompositeView.extend({
  className: 'itemTransactions',
  template: require('./templates/item_transactions'),
  childViewContainer: '.transactions',
  childView: require('modules/transactions/views/transaction_preview'),
  childViewOptions: {
    onItem: true
  }
});
