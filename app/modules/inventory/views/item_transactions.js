import TransactionPreview from 'modules/transactions/views/transaction_preview'
import itemTransactionsTemplate from './templates/item_transactions.hbs'

export default Marionette.CompositeView.extend({
  className: 'itemTransactions',
  template: itemTransactionsTemplate,
  childViewContainer: '.transactions',
  childView: TransactionPreview,
  childViewOptions: {
    onItem: true
  }
})
