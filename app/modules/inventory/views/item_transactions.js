import TransactionPreview from 'modules/transactions/views/transaction_preview'

export default Marionette.CompositeView.extend({
  className: 'itemTransactions',
  template: require('./templates/item_transactions.hbs'),
  childViewContainer: '.transactions',
  childView: TransactionPreview,
  childViewOptions: {
    onItem: true
  }
})
